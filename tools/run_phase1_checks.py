"""Run Phase 1 checks in a separate project and user-data directory.

Usage: python tools/run_phase1_checks.py --godot C:/path/to/godot_console.exe
Optional --copy reuses an existing isolated copy outside the live project root.
Never invokes the city generator, exports, Git writes, or deletes files.
"""
import argparse
import re
import shutil
import subprocess
import sys
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--godot", required=True, type=Path)
parser.add_argument("--copy", type=Path)
args = parser.parse_args()
subprocess.run([sys.executable, str(ROOT / "tools/verify_phase1_preservation.py")], check=True)
token = uuid.uuid4().hex
if args.copy:
    project = args.copy.resolve()
    if project == ROOT or not (project / "project.godot").is_file():
        parser.error("--copy must point to an existing isolated Godot project, not the live project")
    # Never accept an arbitrary project with somebody else's existing progress.
    if not project.is_relative_to(ROOT / "build"):
        parser.error("--copy must be under this project's ignored build directory")
else:
    project = ROOT / "build" / ("phase1-test-" + token)
    shutil.copytree(ROOT, project, ignore=shutil.ignore_patterns(".git", "build"))
config = project / "project.godot"
source = config.read_text(encoding="utf-8")
source, replacements = re.subn(
    r'^config/custom_user_dir_name=.*$',
    f'config/custom_user_dir_name="KurdLingo-Phase1-{token}"',
    source, flags=re.MULTILINE,
)
if replacements != 1 or 'config/use_custom_user_dir=true' not in source:
    parser.error("Could not guarantee isolated user data; no Godot process was launched")
config.write_text(source, encoding="utf-8")
# Do not replay the live editor's copied open-scene session. In Godot 4.7.2 it
# reproduces pre-existing MultiMesh reload errors when both city scenes reopen.
# Preserve that test-copy cache instead of deleting it; imported assets remain.
editor_cache = project / ".godot" / "editor"
if editor_cache.exists():
    if editor_cache.is_symlink() or not editor_cache.resolve().is_relative_to(project):
        parser.error("Editor cache is outside the isolated project; refusing to move it")
    editor_cache.rename(project.parent / ("phase1-editor-cache-" + token))
engine = args.godot.resolve()
logs = project.parent / ("phase1-results-" + token)
logs.mkdir()
checks = [
    ("parse-import", ["--editor", "--import", "--quit"]),
    ("regression", ["--script", "res://tools/verify_phase1.gd"]),
    ("gameplay", ["--", "--self-test"]),
]
for name, extra in checks:
    command = [str(engine), "--headless", "--path", str(project), "--log-file", str(logs / (name + ".log")), *extra]
    result = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace")
    output = result.stdout + result.stderr
    (logs / (name + "-output.log")).write_text(output, encoding="utf-8")
    print(name, "exit", result.returncode, flush=True)
    for line in output.splitlines():
        if "PASS" in line or "READY ms=" in line or "SCRIPT ERROR" in line:
            print(line, flush=True)
    errors = re.findall(r'^(?:SCRIPT )?ERROR:.*$', output, re.MULTILINE)
    expected = ("ERROR: Duplicate world_id:", "ERROR: Saved vocabulary object is missing: apple")
    unexpected = [line for line in errors if name != "regression" or not line.startswith(expected)]
    if result.returncode or unexpected:
        sys.exit(f"Check failed; see {logs}")
    if name == "regression" and "PHASE 1 VERIFICATION PASS" not in output:
        sys.exit(f"Regression suite did not complete; see {logs}")
    if name == "gameplay" and "SELF TEST PASS" not in output:
        sys.exit(f"Gameplay suite did not complete; see {logs}")
print("PHASE 1 ALL CHECKS PASS", "logs:", logs)
