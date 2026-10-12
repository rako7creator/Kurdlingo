# Run from the KurdLingo project root using PowerShell.
# The editor can be open; the script uses its Godot executable to perform
# a one-time headless conversion to citadel/CitadelEditable.tscn.
param([string]$GodotExe = "")
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\project.godot")) { throw "Run this in the KurdLingo project folder." }
if (-not (Test-Path ".\tools\bake_citadel_editable.gd")) { throw "Run prepare before baking." }
if (-not $GodotExe) {
    $process = Get-Process | Where-Object { $_.ProcessName -match 'godot' -and $_.Path } | Select-Object -First 1
    if ($process) { $GodotExe = $process.Path }
}
if (-not $GodotExe) {
    $cmd = Get-Command godot, godot4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) { $GodotExe = $cmd.Source }
}
if (-not $GodotExe -or -not (Test-Path $GodotExe)) {
    throw "Could not find the Godot executable. Open Godot then retry, or pass -GodotExe 'C:\path\Godot.exe'."
}
Write-Host "Using Godot: $GodotExe"
& $GodotExe --headless --path (Get-Location).Path --script "res://tools/bake_citadel_editable.gd"
if ($LASTEXITCODE -ne 0) { throw "Godot baking failed. Exit code $LASTEXITCODE. Do NOT activate. Send the error screenshot." }
if (-not (Test-Path ".\citadel\CitadelEditable.tscn")) { throw "Godot reported success but the editable scene was not found." }
Write-Host "SUCCESS: citadel\CitadelEditable.tscn created. Open the scene in Godot before activating it."
