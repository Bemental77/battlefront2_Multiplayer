<#
  Star Wars Battlefront II (2005) - modern display fix installer.
  Installs Shader Patch (https://github.com/PrismaticFlower/shaderpatch) into the game's GameData
  folder, configures it for whatever monitor you have, fixes shortcuts that force a bad resolution,
  and creates a desktop shortcut. Run Install.bat (or: powershell -ExecutionPolicy Bypass -File Install.ps1).

  -GamePath    Path to the GameData folder (auto-detected if omitted)
  -NoShortcut  Do not create the desktop shortcut
  -Version     Shader Patch release tag to install (default: latest)
  -Elevated    (internal) set when the script relaunches itself as administrator
#>
param(
  [string]$GamePath,
  [switch]$NoShortcut,
  [string]$Version = 'latest',
  [switch]$Elevated
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AppId = 6060

function Say($m) { Write-Host $m }
function Warn($m) { Write-Host "WARNING: $m" -ForegroundColor Yellow }

function Find-GameData {
  $roots = @()
  foreach ($k in 'HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
    $v = (Get-ItemProperty $k -ErrorAction SilentlyContinue)
    if ($v.SteamPath) { $roots += $v.SteamPath } elseif ($v.InstallPath) { $roots += $v.InstallPath }
  }
  $libs = @()
  foreach ($r in ($roots | Select-Object -Unique)) {
    $libs += $r
    $vdf = Join-Path $r 'steamapps\libraryfolders.vdf'
    if (Test-Path $vdf) {
      foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) { $libs += ($m.Groups[1].Value -replace '\\\\', '\') }
    }
  }
  foreach ($l in ($libs | Select-Object -Unique)) {
    foreach ($name in 'Star Wars Battlefront II Classic', 'Star Wars Battlefront II') {
      $gd = Join-Path $l "steamapps\common\$name\GameData"
      if (Test-Path (Join-Path $gd 'BattlefrontII.exe')) { return $gd }
    }
  }
  $cands = @('C:\GOG Games\Star Wars Battlefront II\GameData',
             'C:\Program Files (x86)\GOG Galaxy\Games\Star Wars Battlefront II\GameData',
             'C:\Program Files (x86)\LucasArts\Star Wars Battlefront II\GameData',
             'C:\Program Files\LucasArts\Star Wars Battlefront II\GameData')
  foreach ($d in 'C', 'D', 'E', 'F') { $cands += "${d}:\Games\Star Wars Battlefront II\GameData" }
  foreach ($gd in $cands) { if (Test-Path (Join-Path $gd 'BattlefrontII.exe')) { return $gd } }
  return $null
}

# Set "Key: value" in a Shader Patch yml, keeping comments and layout.
function Set-Yml($text, $key, $value) {
  $pattern = '(?m)^(\s*' + [regex]::Escape($key) + ':\s*).*$'
  if ($text -match $pattern) { return [regex]::Replace($text, $pattern, { param($m) $m.Groups[1].Value + $value }) }
  return $text
}

# ---- locate the game ------------------------------------------------------------------------
if (-not $GamePath) { $GamePath = Find-GameData }
if (-not $GamePath) {
  Say 'Could not find the game automatically.'
  $GamePath = Read-Host 'Paste the full path to your GameData folder (the one containing BattlefrontII.exe)'
}
$GamePath = $GamePath.Trim('"').TrimEnd('\')
if (-not (Test-Path (Join-Path $GamePath 'BattlefrontII.exe'))) {
  throw "BattlefrontII.exe not found in '$GamePath'. Point -GamePath at the GameData folder."
}
Say "Game folder: $GamePath"
if (Get-Process BattlefrontII -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$GamePath\*" }) { throw 'Close Battlefront II first, then run this again.' }

# ---- system checks --------------------------------------------------------------------------
$build = [Environment]::OSVersion.Version.Build
if ($build -lt 18363) { Warn "Windows build $build is older than Windows 10 1909; Shader Patch may not run." }
if (-not [Environment]::Is64BitOperatingSystem) { Warn '32-bit Windows detected; Shader Patch is untested there.' }

# ---- need admin to write here? relaunch elevated --------------------------------------------
$probe = Join-Path $GamePath ('.bf2fix_probe_' + [guid]::NewGuid().ToString('N'))
try { Set-Content $probe 'x'; Remove-Item $probe -Force }
catch {
  if ($Elevated) { throw "Cannot write to '$GamePath' even as administrator." }
  Say 'The game folder needs administrator rights. Asking Windows for permission...'
  $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-GamePath', "`"$GamePath`"", '-Version', $Version, '-Elevated')
  if ($NoShortcut) { $a += '-NoShortcut' }
  Start-Process powershell -Verb RunAs -ArgumentList $a -Wait
  exit
}

# ---- download Shader Patch ------------------------------------------------------------------
$work = Join-Path ([IO.Path]::GetTempPath()) ('bf2fix_' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $work | Out-Null
$yml = Join-Path $GamePath 'shader patch.yml'
try {
  $api = if ($Version -eq 'latest') { 'https://api.github.com/repos/PrismaticFlower/shaderpatch/releases/latest' } else { "https://api.github.com/repos/PrismaticFlower/shaderpatch/releases/tags/$Version" }
  $rel = Invoke-RestMethod $api -Headers @{ 'User-Agent' = 'bf2-display-fix' }
  $asset = $rel.assets | Where-Object name -eq 'shaderpatch.zip' | Select-Object -First 1
  if (-not $asset) { throw 'shaderpatch.zip not found in the release.' }
  Say "Downloading Shader Patch $($rel.tag_name)..."
  $zip = Join-Path $work 'shaderpatch.zip'
  Invoke-WebRequest $asset.browser_download_url -OutFile $zip -UseBasicParsing
  $src = Join-Path $work 'x'
  Expand-Archive $zip $src -Force

  # ---- back up anything we would overwrite (first install only), then install ---------------
  $backup = Join-Path $GamePath 'bf2fix_backup'
  $firstInstall = -not (Test-Path $backup)
  New-Item -ItemType Directory -Force $backup | Out-Null
  if ($firstInstall) {
    foreach ($f in 'd3d9.dll', 'd3dcompiler_47.dll', 'shader patch.yml') {
      $t = Join-Path $GamePath $f
      if (Test-Path $t) { Copy-Item $t $backup }
    }
  }
  $keepYml = $null
  if (Test-Path $yml) { $keepYml = Get-Content $yml -Raw }   # keep the user's own settings on reinstall
  Copy-Item (Join-Path $src '*') $GamePath -Recurse -Force -Exclude 'Shader Patch Installer.exe'
  Copy-Item (Join-Path $src 'Shader Patch Installer.exe') (Join-Path $GamePath 'Shader Patch Settings.exe') -Force
  if ($keepYml) { Set-Content $yml $keepYml -NoNewline }
} finally {
  Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}

# ---- configure for this machine's monitor ---------------------------------------------------
Add-Type @"
using System; using System.Runtime.InteropServices;
public class BF2Screen {
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern int GetSystemMetrics(int i);
}
"@
[void][BF2Screen]::SetProcessDPIAware()
$w = [BF2Screen]::GetSystemMetrics(0); $h = [BF2Screen]::GetSystemMetrics(1)   # primary monitor, physical pixels
$ratio = [math]::Round($w / $h, 2)
$kind = if ($ratio -lt 1.4) { '4:3 / 5:4' } elseif ($ratio -lt 1.7) { '16:10' } elseif ($ratio -le 1.8) { '16:9' } elseif ($ratio -le 2.6) { '21:9 ultrawide' } else { 'super-ultrawide' }
$ultra = $ratio -gt 1.8   # anything wider than 16:9 needs the aspect ratio hack to fill the screen
$text = Get-Content $yml -Raw
$text = Set-Yml $text 'Aspect Ratio Hack' $(if ($ultra) { 'yes' } else { 'no' })
$text = Set-Yml $text 'Treat 800x600 As Interface' 'yes'   # menus render in their native 4:3 layout
$text = Set-Yml $text 'Stretch Interface' 'no'              # ...pillarboxed instead of stretched
$text = Set-Yml $text 'Display Scaling Aware' 'yes'         # sharp at any Windows scaling (125%, 150%, 4K)
$text = Set-Yml $text 'Display Scaling' 'yes'
Set-Content $yml $text -NoNewline
Say ("Main monitor: {0}x{1} ({2}, ratio {3}) -> Aspect Ratio Hack: {4}" -f $w, $h, $kind, $ratio, $(if ($ultra) { 'on' } else { 'off' }))

# ---- remove forced resolutions from existing shortcuts (the Remaster's own shortcut sets one) ----
$shell = New-Object -ComObject WScript.Shell
$dirs = @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('CommonDesktopDirectory'),
          [Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('CommonPrograms'),
          (Split-Path $GamePath)) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique
foreach ($d in $dirs) {
  Get-ChildItem $d -Filter *.lnk -Recurse -Depth 2 -ErrorAction SilentlyContinue | ForEach-Object {
    try {
      $s = $shell.CreateShortcut($_.FullName)
      if ($s.TargetPath -match 'BattlefrontII\.exe$' -and $s.Arguments -match '/resolution') {
        $s.Arguments = ($s.Arguments -replace '/resolution\s+\d+\s+\d+', '').Trim()
        $s.Save()
        Say "Removed forced resolution from shortcut: $($_.FullName)"
      }
    } catch { }
  }
}

# ---- warn about a forced resolution in Steam launch options ---------------------------------
Get-ChildItem (Join-Path (Split-Path (Split-Path (Split-Path (Split-Path $GamePath)))) 'userdata') -Filter localconfig.vdf -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
  $t = Get-Content $_.FullName -Raw
  if ($t -match '(?s)"6060"\s*\{[^}]*?"LaunchOptions"\s+"[^"]*/resolution') {
    Warn 'Steam launch options for this game contain /resolution. Remove it: Steam > right-click the game > Properties > Launch Options.'
  }
}

# ---- desktop shortcut -----------------------------------------------------------------------
if (-not $NoShortcut) {
  $exe = Join-Path $GamePath 'BattlefrontII.exe'
  $steam = $null
  if ($GamePath -match 'steamapps') {
    $steam = Join-Path (($GamePath -split '\\steamapps\\')[0]) 'steam.exe'
  }
  $lnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Star Wars Battlefront II HD.lnk'
  $s = $shell.CreateShortcut($lnk)
  if ($steam -and (Test-Path $steam)) {
    $s.TargetPath = $steam; $s.Arguments = "-applaunch $AppId"; $s.WorkingDirectory = (Split-Path $steam)
  } else {
    $s.TargetPath = $exe; $s.Arguments = ''; $s.WorkingDirectory = $GamePath
  }
  $s.IconLocation = "$exe,0"
  $s.Save()
  Say "Shortcut created: $lnk"
}

Say ''
Say 'Done. Launch the game from the "Star Wars Battlefront II HD" shortcut.'
Say 'Do NOT force a resolution (/resolution) on a widescreen or ultrawide monitor.'
