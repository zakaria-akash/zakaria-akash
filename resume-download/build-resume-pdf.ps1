<#
    Builds Zakaria_Ibrahim_Resume_2026.pdf from resume-print.html

    Usage:  powershell -ExecutionPolicy Bypass -File build-resume-pdf.ps1

    Steps:
      1. Downloads the GitHub avatar and inlines it as a base64 data URI
         (so the PDF has no network dependency).
      2. Renders the page to A4 PDF with headless Chrome.

    Requires: Google Chrome (or Microsoft Edge - see $browser below).
#>

$ErrorActionPreference = "Stop"

$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$src     = Join-Path $here "resume-print.html"
$out     = Join-Path $here "Zakaria_Ibrahim_Resume_2026.pdf"
$work    = Join-Path $env:TEMP "resume-build"
$render  = Join-Path $work "resume-render.html"
$avatar  = Join-Path $work "avatar.png"
$profile = Join-Path $work "chrome-profile"

$browser = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $browser) { throw "Chrome or Edge not found - install one to build the PDF." }

New-Item -ItemType Directory -Force -Path $work | Out-Null

# --- 1. avatar -> base64 data URI -------------------------------------------
Write-Host "Fetching avatar..."
Invoke-WebRequest -Uri "https://github.com/zakaria-akash.png?size=400" -OutFile $avatar -UseBasicParsing
$dataUri = "data:image/png;base64," + [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($avatar))

# --- 2. inline it (read/write as UTF-8 so emoji survive) --------------------
$utf8 = New-Object System.Text.UTF8Encoding($false)
$html = [System.IO.File]::ReadAllText($src, $utf8).Replace("__AVATAR__", $dataUri)
[System.IO.File]::WriteAllText($render, $html, $utf8)

# --- 3. render to PDF -------------------------------------------------------
Write-Host "Rendering PDF with $(Split-Path -Leaf $browser)..."
$url = "file:///" + ($render.Replace('\','/'))
$args = @(
    "--headless=new", "--disable-gpu", "--no-sandbox",
    "--user-data-dir=$profile",
    "--no-pdf-header-footer",
    "--run-all-compositor-stages-before-draw",
    "--virtual-time-budget=8000",
    "--print-to-pdf=$out",
    $url
)
$p = Start-Process -FilePath $browser -ArgumentList $args -Wait -PassThru -WindowStyle Hidden
if ($p.ExitCode -ne 0) { throw "Browser exited with code $($p.ExitCode)" }

if (Test-Path $out) {
    Write-Host ("Done -> {0} ({1:N0} bytes)" -f $out, (Get-Item $out).Length)
} else {
    throw "PDF was not produced."
}
