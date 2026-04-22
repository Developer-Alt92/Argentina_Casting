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

function Test-GalleryDlExe {
    param([Parameter(Mandatory = $true)][string]$ExePath)

    if (-not (Test-Path -LiteralPath $ExePath)) {
        return $false
    }

    $versionOut = & $ExePath --version 2>$null
    return ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($versionOut | Out-String)))
}

function Ensure-GalleryDl {
    param(
        [Parameter(Mandatory = $true)][string]$ExePath,
        [Parameter(Mandatory = $true)][string]$ToolsDir
    )

    $tempExe = Join-Path $ToolsDir "gallery-dl.download.exe"
    $sources = @(
        "https://github.com/gdl-org/builds/releases/latest/download/gallery-dl_windows.exe",
        "https://github.com/mikf/gallery-dl/releases/latest/download/gallery-dl.exe"
    )

    if (Test-GalleryDlExe -ExePath $ExePath) {
        return
    }

    if (Test-Path -LiteralPath $ExePath) {
        Write-Host "gallery-dl existente inválido. Lo voy a reemplazar..." -ForegroundColor Yellow
        Remove-Item -LiteralPath $ExePath -Force
    }

    foreach ($url in $sources) {
        if (Test-Path -LiteralPath $tempExe) {
            Remove-Item -LiteralPath $tempExe -Force
        }

        try {
            Download-File -Url $url -Destination $tempExe

            if (Test-GalleryDlExe -ExePath $tempExe) {
                Move-Item -LiteralPath $tempExe -Destination $ExePath -Force
                return
            }
            else {
                Write-Warning "El binario descargado desde '$url' no pasó la verificación de --version."
            }
        }
        catch {
            Write-Warning "Falló la descarga desde '$url': $($_.Exception.Message)"
        }
    }

    throw "No se pudo obtener un ejecutable válido de gallery-dl."
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

Ensure-GalleryDl -ExePath $galleryDlExe -ToolsDir $toolsDir

if (-not (Test-GalleryDlExe -ExePath $galleryDlExe)) {
    throw "No se pudo validar gallery-dl.exe después de la descarga."
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

$versionShown = (& $galleryDlExe --version 2>$null | Out-String).Trim()

Write-Host ""
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host "Cuenta   : $AccountUrl" -ForegroundColor Green
Write-Host "Salida   : $OutDir" -ForegroundColor Green
Write-Host "Config   : $configPath" -ForegroundColor Green
Write-Host "Archive  : $archiveDb" -ForegroundColor Green
Write-Host "Skip     : activado (no sobrescribe duplicados)" -ForegroundColor Green
Write-Host "Version  : $versionShown" -ForegroundColor Green
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
