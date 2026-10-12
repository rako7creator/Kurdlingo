# Run from your KurdLingo project folder. Godot editor can stay open.
param([string]$GodotExe = "")
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\project.godot")) { throw "Open VS Code terminal in KurdLingo project folder first." }
if (-not $GodotExe) {
  $godot = Get-Process | Where-Object { $_.ProcessName -match 'godot' -and $_.Path } | Select-Object -First 1
  if ($godot) { $GodotExe = $godot.Path }
}
if (-not $GodotExe) {
  $cmd = Get-Command godot, godot4 -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($cmd) { $GodotExe = $cmd.Source }
}
if (-not $GodotExe -or -not (Test-Path $GodotExe)) {
  throw "Start Godot editor first or pass -GodotExe 'C:\path\to\Godot.exe'."
}
Write-Host "Running Godot builders with: $GodotExe"
foreach ($script in @("res://tools/bake_school_editable.gd", "res://tools/create_future_editable_templates.gd")) {
  Write-Host "BUILDING: $script"
  & $GodotExe --headless --path (Get-Location).Path --script $script
  if ($LASTEXITCODE -ne 0) { throw "Godot scene generation failed: $script. Do not activate; send the terminal screenshot." }
}
Write-Host "FINISHED: Please inspect SchoolEditable.tscn and modules_editable scenes in Godot before activation."
