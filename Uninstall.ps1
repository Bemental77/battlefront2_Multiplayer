<#
  Removes Shader Patch from Battlefront II and restores any files the installer backed up.
  -GamePath  Path to the GameData folder (auto-detected from the desktop shortcut's install if omitted)
#>
param([string]$GamePath)
$ErrorActionPreference = 'Stop'
if (-not $GamePath) {
  $GamePath = Read-Host 'Paste the full path to your GameData folder (the one containing BattlefrontII.exe)'
}
$GamePath = $GamePath.Trim('"').TrimEnd('\')
if (-not (Test-Path (Join-Path $GamePath 'BattlefrontII.exe'))) { throw "BattlefrontII.exe not found in '$GamePath'." }
if (Get-Process BattlefrontII -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$GamePath\*" }) { throw 'Close Battlefront II first.' }

foreach ($f in 'd3d9.dll', 'd3dcompiler_47.dll', 'shader patch acknowledgements.txt', 'shader patch license.txt',
               'shader patch readme.txt', 'shader patch.yml', 'Shader Patch Settings.exe', 'Shader Patch Installer.exe') {
  Remove-Item -LiteralPath (Join-Path $GamePath $f) -Force -ErrorAction SilentlyContinue
}
Remove-Item -LiteralPath (Join-Path $GamePath 'data\shaderpatch') -Recurse -Force -ErrorAction SilentlyContinue

$backup = Join-Path $GamePath 'bf2fix_backup'
if (Test-Path $backup) {
  Copy-Item (Join-Path $backup '*') $GamePath -Force
  Remove-Item $backup -Recurse -Force
}
Write-Host 'Shader Patch removed. You can delete the desktop shortcut if you no longer want it.'
