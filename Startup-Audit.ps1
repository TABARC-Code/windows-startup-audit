# TABARC-Code
param([string]$OutDir = "$PSScriptRoot\snapshots")

if (-not (Test-Path -LiteralPath $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

$ts = (Get-Date).ToString("yyyyMMdd_HHmmss")
$out = Join-Path $OutDir "startup_$ts.json"

$items = New-Object System.Collections.Generic.List[object]

function Add-Item([string]$Type,[string]$Name,[string]$Command,[string]$Location) {
  $items.Add([pscustomobject]@{ type=$Type; name=$Name; command=$Command; location=$Location }) | Out-Null
}

$runKeys = @(
  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
  "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
  "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($k in $runKeys) {
  if (Test-Path $k) {
    $props = Get-ItemProperty $k
    foreach ($p in $props.PSObject.Properties) {
      if ($p.Name -in "PSPath","PSParentPath","PSChildName","PSDrive","PSProvider") { continue }
      Add-Item "RegistryRun" $p.Name ([string]$p.Value) $k
    }
  }
}

$startupFolders = @(
  [Environment]::GetFolderPath("Startup"),
  "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
)

foreach ($f in $startupFolders) {
  if (Test-Path $f) {
    Get-ChildItem -LiteralPath $f -File -ErrorAction SilentlyContinue | ForEach-Object {
      Add-Item "StartupFolder" $_.Name $_.FullName $f
    }
  }
}

Get-ScheduledTask -ErrorAction SilentlyContinue | ForEach-Object {
  $t = $_
  try {
    $actions = ($t.Actions | ForEach-Object { ("{0} {1}" -f $_.Execute, $_.Arguments).Trim() }) -join " | "
    Add-Item "ScheduledTask" ($t.TaskPath + $t.TaskName) $actions "Task Scheduler"
  } catch {}
}

$items | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $out -Encoding UTF8
Write-Host "Wrote $out"
