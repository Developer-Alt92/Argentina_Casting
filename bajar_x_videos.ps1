param(
    [string]$AccountUrl = "https://x.com/ArgentCasting",
    [string]$OutDir = "$PWD\ArgentCasting_videos",
    [ValidateSet("firefox","chrome","edge","brave","chromium")]
    [string]$Browser = "firefox",
    [string]$CookiesFile = ""
)

$ErrorActionPreference = "Stop"

function Ensure-Dir {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Download-File {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    Write-Host "Descargando: $Url" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$baseDir  = (Get-Location).Path
$toolsDir = Join-Path $baseDir "tools"

Ensure-Dir $toolsDir
Ensure-Dir $OutDir

$galleryDlExe = Join-Path $toolsDir "gallery-dl.exe"
$configPath   = Join-Path $OutDir "gallery-dl-config.json"
$archiveDb    = Join-Path $OutDir "archive.sqlite3"
$stdoutFile   = Join-Path $OutDir "gallery-dl.stdout.log"
$stderrFile   = Join-Path $OutDir "gallery-dl.stderr.log"
$logPath      = Join-Path $OutDir "descarga.log"

if (-not (Test-Path -LiteralPath $galleryDlExe)) {
    Write-Host "No encontré gallery-dl.exe. Lo voy a descargar..." -ForegroundColor Yellow
    $galleryUrl = "https://github.com/mikf/gallery-dl/releases/latest/download/gallery-dl.exe"
    Download-File -Url $galleryUrl -Destination $galleryDlExe
}

if (-not (Test-Path -LiteralPath $galleryDlExe)) {
    throw "No se pudo descargar gallery-dl.exe"
}

if ([string]::IsNullOrWhiteSpace($CookiesFile)) {
    $cookieSource = @($Browser)
}
else {
    if (-not (Test-Path -LiteralPath $CookiesFile)) {
        throw "No existe el archivo de cookies: $CookiesFile"
    }
    $cookieSource = (Resolve-Path $CookiesFile).Path
}

$configObject = @{
    extractor = @{
        "base-directory" = (Resolve-Path $OutDir).Path
        archive          = $archiveDb
        skip             = $true
        twitter          = @{
            include  = @("media")
            cookies  = $cookieSource
            filename = "{author[name]}_{tweet_id}_{num}.{extension}"
        }
    }
}

$json = $configObject | ConvertTo-Json -Depth 20
$null = $json | ConvertFrom-Json
Write-Utf8NoBom -Path $configPath -Content $json

if (-not (Test-Path -LiteralPath $configPath)) {
    throw "No se creó el archivo de configuración."
}

$fileInfo = Get-Item -LiteralPath $configPath
if ($fileInfo.Length -le 2) {
    throw "El archivo de configuración quedó vacío o inválido: $configPath"
}

if (Test-Path $stdoutFile) { Remove-Item $stdoutFile -Force }
if (Test-Path $stderrFile) { Remove-Item $stderrFile -Force }
if (Test-Path $logPath)    { Remove-Item $logPath -Force }

$arguments = @(
    "--config", $configPath,
    "--filter", "extension in ('mp4','m4v','mov','webm')",
    $AccountUrl
)

Write-Host ""
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host "Cuenta  : $AccountUrl" -ForegroundColor Green
Write-Host "Salida  : $OutDir" -ForegroundColor Green
Write-Host "Config  : $configPath" -ForegroundColor Green
Write-Host "Archive : $archiveDb" -ForegroundColor Green
Write-Host "Skip    : activado (no sobrescribe duplicados)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host ""

$proc = Start-Process `
    -FilePath $galleryDlExe `
    -ArgumentList $arguments `
    -NoNewWindow `
    -Wait `
    -PassThru `
    -RedirectStandardOutput $stdoutFile `
    -RedirectStandardError $stderrFile

if (Test-Path $stdoutFile) {
    Get-Content $stdoutFile | Tee-Object -FilePath $logPath -Append
}

if (Test-Path $stderrFile) {
    Get-Content $stderrFile | Tee-Object -FilePath $logPath -Append
}

Write-Host ""
Write-Host "ExitCode gallery-dl: $($proc.ExitCode)" -ForegroundColor Cyan
Write-Host "Log combinado: $logPath" -ForegroundColor Yellow
Write-Host "STDOUT: $stdoutFile" -ForegroundColor Yellow
Write-Host "STDERR: $stderrFile" -ForegroundColor Yellow

if ($proc.ExitCode -ne 0) {
    throw "gallery-dl terminó con código $($proc.ExitCode). Revisa el log y el archivo STDERR."
}

$videos = Get-ChildItem -LiteralPath $OutDir -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in ".mp4", ".m4v", ".mov", ".webm" }

Write-Host ""
Write-Host "Proceso terminado." -ForegroundColor Green
Write-Host ("Videos descargados/encontrados: {0}" -f $videos.Count) -ForegroundColor Green
Write-Host "Log: $logPath" -ForegroundColor Yellow
