$ErrorActionPreference = "Stop"

function Resolve-EdgePath {
  $candidates = @(
    "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
  ) | Where-Object { $_ -and (Test-Path $_) }
  $candidates = @($candidates)

  if ($candidates.Count -gt 0) { return $candidates[0] }

  # Last resort: try App Paths registry
  $regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe"
  )
  foreach ($rp in $regPaths) {
    try {
      $p = (Get-ItemProperty -Path $rp -Name "(default)" -ErrorAction Stop)."(default)"
      if ($p -and (Test-Path $p)) { return $p }
    } catch {}
  }

  throw "Microsoft Edge (msedge.exe) non trovato."
}

function To-FileUrl([string]$path) {
  return ([System.Uri]::new((Resolve-Path $path))).AbsoluteUri
}

function Ensure-Dir([string]$dir) {
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
}

$root = (Resolve-Path ".").Path
$outRoot = Join-Path $root "_visual_check"
$outDesktop = Join-Path $outRoot "desktop"
$outMobile = Join-Path $outRoot "mobile"
Ensure-Dir $outRoot
Ensure-Dir $outDesktop
Ensure-Dir $outMobile

$edge = Resolve-EdgePath
Write-Host ("Edge: {0}" -f $edge)

function Get-AllLessonPages([string]$lezDir) {
  return @(Get-ChildItem -Path $lezDir -Filter "*.html" | Sort-Object Name | ForEach-Object { $_.FullName })
}

$pages = @()
$pages += (Join-Path $root "index.html")
$pages += (Join-Path $root "programma.html")
$pages += Get-AllLessonPages (Join-Path $root "lez1")
$pages += Get-AllLessonPages (Join-Path $root "lez2")
$pages += Get-AllLessonPages (Join-Path $root "lez3")
$pages += Get-AllLessonPages (Join-Path $root "lez4")

$pages = $pages | Where-Object { Test-Path $_ } | Select-Object -Unique

Write-Host ("Pagine da screenshot: {0}" -f $pages.Count)

function Take-Screenshot([string]$filePath, [string]$outDir, [int]$w, [int]$h, [string]$suffix, [string]$userAgent) {
  $rel = $filePath.Substring($root.Length).TrimStart("\","/")
  $base = ($rel -replace '[<>:"/\\|?*\x00-\x1F]', '_')
  $png = Join-Path $outDir ($base.Replace(".html", "") + $suffix + ".png")
  $url = To-FileUrl $filePath

  $args = @(
    "--no-first-run",
    "--no-default-browser-check",
    "--headless=new",
    "--disable-gpu",
    "--disable-extensions",
    "--disable-background-networking",
    "--disable-sync",
    "--disable-component-update",
    "--metrics-recording-only",
    "--disable-default-apps",
    "--mute-audio",
    "--log-level=3",
    "--disable-logging",
    "--hide-scrollbars",
    "--window-size=$w,$h",
    "--virtual-time-budget=8000",
    "--screenshot=$png",
    $url
  )
  if ($userAgent) { $args = @("--user-agent=$userAgent") + $args }

  & $edge @args | Out-Null
  if (-not (Test-Path $png)) { throw "Screenshot non creato: $png" }
  return $png
}

$mobileUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"

$results = @()
foreach ($p in $pages) {
  try {
    $d = Take-Screenshot -filePath $p -outDir $outDesktop -w 1280 -h 720 -suffix "__desktop" -userAgent ""
    $m = Take-Screenshot -filePath $p -outDir $outMobile -w 390 -h 844 -suffix "__mobile" -userAgent $mobileUA
    $results += [pscustomobject]@{ page = $p.Substring($root.Length).TrimStart("\","/"); desktop = $d.Substring($root.Length).TrimStart("\","/"); mobile = $m.Substring($root.Length).TrimStart("\","/"); ok = $true }
  } catch {
    $results += [pscustomobject]@{ page = $p.Substring($root.Length).TrimStart("\","/"); desktop = ""; mobile = ""; ok = $false; error = $_.Exception.Message }
  }
}

$reportPath = Join-Path $outRoot "edge-screenshots.json"
$results | ConvertTo-Json -Depth 4 | Set-Content -Path $reportPath -Encoding UTF8

$ok = ($results | Where-Object { $_.ok }).Count
$ko = ($results | Where-Object { -not $_.ok }).Count
Write-Host ("OK: {0}  KO: {1}" -f $ok, $ko)
Write-Host ("Report: {0}" -f $reportPath.Substring($root.Length).TrimStart("\","/"))
