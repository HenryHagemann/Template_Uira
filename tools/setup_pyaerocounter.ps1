<#
.SYNOPSIS
  Baixa o PyAeroCounter.exe oficial e valida/instala dependencias (Tesseract).
.DESCRIPTION
  Executar UMA VEZ apos clonar o repositorio.
  Re-executar se quiser forcar redownload do .exe (-Force).
  Para instalar o Tesseract com PATH permanente, rode como Administrador.
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# User-Agent de navegador + TLS 1.2
$UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# -------------------------------------------------------------------
# Paths
# -------------------------------------------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Join-Path $ScriptDir 'pyaerocounter'
$ExePath   = Join-Path $TargetDir 'PyAeroCounter.exe'
$ExeUrl    = 'https://raw.githubusercontent.com/comissao-aerodesign/PyAeroCounter/master/dist/PyAeroCounter.exe'
$ZipUrl    = 'https://raw.githubusercontent.com/comissao-aerodesign/PyAeroCounter/master/dist/PyAeroCounter.zip'

$DefaultTessPath = "C:\Program Files\Tesseract-OCR"

# -------------------------------------------------------------------
# Helper: download com User-Agent + fallback BITS
# -------------------------------------------------------------------
function Get-RemoteFile {
    param([string]$Url, [string]$OutFile)
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -UserAgent $UA
    } catch {
        Write-Host "    [!] Invoke-WebRequest falhou, tentando BITS..." -ForegroundColor Yellow
        Start-BitsTransfer -Source $Url -Destination $OutFile
    }
}

# -------------------------------------------------------------------
# 1. Download do PyAeroCounter.exe (com fallback .zip)
# -------------------------------------------------------------------
if ((Test-Path $ExePath) -and -not $Force) {
    Write-Host "[OK] PyAeroCounter.exe ja presente em: $ExePath" -ForegroundColor Green
    Write-Host "     (use -Force para baixar novamente)" -ForegroundColor DarkGray
} else {
    Write-Host "[..] Baixando PyAeroCounter.exe..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    try {
        Get-RemoteFile -Url $ExeUrl -OutFile $ExePath
        Write-Host "[OK] Download concluido: $ExePath" -ForegroundColor Green
    } catch {
        Write-Host "[!] Falha no .exe. Tentando o .zip..." -ForegroundColor Yellow
        $ZipPath = Join-Path $TargetDir 'PyAeroCounter.zip'
        try {
            Get-RemoteFile -Url $ZipUrl -OutFile $ZipPath
            Expand-Archive -Path $ZipPath -DestinationPath $TargetDir -Force
            Remove-Item $ZipPath -Force
            Write-Host "[OK] Extraido do .zip: $ExePath" -ForegroundColor Green
        } catch {
            Write-Host "[ERRO] Falha no download (.exe e .zip): $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    }
}

# -------------------------------------------------------------------
# 2. Verificacao / Instalacao do Tesseract
# -------------------------------------------------------------------
Write-Host ""
Write-Host "[..] Verificando Tesseract OCR..." -ForegroundColor Cyan

$tesseract = Get-Command tesseract -ErrorAction SilentlyContinue

# Tenta o caminho padrao caso nao esteja no PATH ainda
if (-not $tesseract -and (Test-Path (Join-Path $DefaultTessPath 'tesseract.exe'))) {
    $env:Path += ";$DefaultTessPath"
    $tesseract = Get-Command tesseract -ErrorAction SilentlyContinue
}

if ($tesseract) {
    $version = (& tesseract --version 2>&1 | Select-Object -First 1)
    Write-Host "[OK] Tesseract encontrado: $version" -ForegroundColor Green
} else {
    Write-Host "[..] Tesseract nao encontrado. Tentando instalar..." -ForegroundColor Yellow

    $installed = $false

    # --- Tentativa 1: winget (mais confiavel, sem 403) ---
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "    -> Instalando via winget..." -ForegroundColor Cyan
        try {
            winget install --id UB-Mannheim.TesseractOCR -e --silent `
                --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) { $installed = $true }
        } catch {
            Write-Host "    [!] winget falhou: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "    [!] winget nao disponivel." -ForegroundColor DarkGray
    }

    # --- Tentativa 2: download direto do GitHub Releases (sem anti-bot) ---
    if (-not $installed) {
        Write-Host "    -> Tentando baixar do GitHub Releases..." -ForegroundColor Cyan
        $TessUrl       = 'https://github.com/UB-Mannheim/tesseract/releases/download/v5.4.0.20240606/tesseract-ocr-w64-setup-5.4.0.20240606.exe'
        $TessInstaller = Join-Path $env:TEMP 'tesseract-setup.exe'
        try {
            Get-RemoteFile -Url $TessUrl -OutFile $TessInstaller
            Write-Host "    -> Instalando silenciosamente..." -ForegroundColor Cyan
            Start-Process -FilePath $TessInstaller -ArgumentList '/S' -Wait
            $installed = $true
        } catch {
            Write-Host "    [!] Download do GitHub falhou: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    # --- Verificacao pos-instalacao + PATH permanente ---
    if ($installed -and (Test-Path (Join-Path $DefaultTessPath 'tesseract.exe'))) {
        try {
            $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
            if ($machinePath -notlike "*$DefaultTessPath*") {
                [Environment]::SetEnvironmentVariable('Path', "$machinePath;$DefaultTessPath", 'Machine')
                Write-Host "[OK] Tesseract adicionado ao PATH do sistema (permanente)." -ForegroundColor Green
            }
        } catch {
            Write-Host "[!] Sem permissao para PATH do sistema. Gravando no PATH do usuario..." -ForegroundColor Yellow
            $userPath = [Environment]::GetEnvironmentVariable('Path','User')
            if ($userPath -notlike "*$DefaultTessPath*") {
                [Environment]::SetEnvironmentVariable('Path', "$userPath;$DefaultTessPath", 'User')
                Write-Host "[OK] Adicionado ao PATH do usuario (permanente)." -ForegroundColor Green
            }
        }
        $env:Path += ";$DefaultTessPath"
        $tesseract = Get-Command tesseract -ErrorAction SilentlyContinue
    }

    if ($tesseract) {
        $version = (& tesseract --version 2>&1 | Select-Object -First 1)
        Write-Host "[OK] Tesseract instalado: $version" -ForegroundColor Green
        Write-Host "     OBS: reinicie o terminal/VS Code para o PATH valer globalmente." -ForegroundColor DarkGray
    } else {
        Write-Host "[ERRO] Nao foi possivel instalar o Tesseract automaticamente." -ForegroundColor Red
        Write-Host "       Instale manualmente: https://github.com/UB-Mannheim/tesseract/wiki" -ForegroundColor Yellow
        Write-Host "       Ou rode: winget install UB-Mannheim.TesseractOCR" -ForegroundColor Yellow
        exit 1
    }
}

# -------------------------------------------------------------------
# Conclusao
# -------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host " Setup concluido. Use a task 'SAE Word Count' no VS Code"        -ForegroundColor Green
Write-Host " ou execute manualmente: tools/count_words.ps1"                   -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
