"""Read-only preservation check against the Phase 1 checkpoint manifest."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
checkpoint = ROOT / "build/phase1/baseline-sha256.json"
if not checkpoint.exists(): checkpoint = ROOT / "tools/phase1_preservation.json"
baseline = json.loads(checkpoint.read_text())
allowed = {
    "scripts/main.gd", "scripts/world_editor_layout.gd", "scripts/teacher_circle.gd",
    "scenes/editable_world.tscn", "EDITING-WORLD.md",
}
for name, expected in baseline.items():
    path = ROOT / name
    assert path.is_file(), f"Original file missing: {name}"
    if name.replace("\\", "/") in allowed:
        continue
    assert hashlib.sha256(path.read_bytes()).hexdigest() == expected, f"Original file changed: {name}"
scene = ROOT / "scenes/editable_world.tscn"
original_bytes = re.sub(
    rb'^metadata/world_(?:id|role|key|collision) = [^\r\n]*\r?\n',
    b'', scene.read_bytes(), flags=re.MULTILINE,
)
assert hashlib.sha256(original_bytes).hexdigest() == baseline["scenes\\editable_world.tscn"]
blocks = re.split(r'(?=\[node )', scene.read_text(encoding="utf-8"))[1:]
identities = []
words = []
for block in blocks:
    match = re.search(r'metadata/world_id = "([^"]+)"', block)
    if match:
        identities.append(match[1])
    if 'metadata/world_role = "word"' in block:
        words.append(re.search(r'metadata/world_key = "([^"]+)"', block)[1])
assert len(identities) == len(set(identities)), "Duplicate persistent ID"
vocabulary = json.loads((ROOT / "data/vocabulary.json").read_text(encoding="utf-8"))
assert len(words) == 1000 and set(words) == {row["id"] for row in vocabulary}
print(f"PRESERVATION PASS: {len(baseline)} original files retained; scene changes are metadata only; 1,000 word IDs and all assets unchanged.")
