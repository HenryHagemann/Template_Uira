<#
.SYNOPSIS
  Baixa o PyAeroCounter.exe oficial e valida dependências (Tesseract, pdftohtml).
.DESCRIPTION
  Executar UMA VEZ após clonar o repositório.
  Re-executar se quiser forçar redownload do .exe.
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# -------------------------------------------------------------------
# Paths
# -------------------------------------------------------------------
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir   = Join-Path $ScriptDir 'pyaerocounter'
$ExePath     = Join-Path $TargetDir 'PyAeroCounter.exe'
$ExeUrl      = 'https://raw.githubusercontent.com/comissao-aerodesign/PyAeroCounter/master/dist/PyAeroCounter.exe'

# -------------------------------------------------------------------
# 1. Download do PyAeroCounter.exe
# -------------------------------------------------------------------
if ((Test-Path $ExePath) -and -not $Force) {
    Write-Host "[OK] PyAeroCounter.exe ja presente em: $ExePath" -ForegroundColor Green
    Write-Host "     (use -Force para baixar novamente)" -ForegroundColor DarkGray
} else {
    Write-Host "[..] Baixando PyAeroCounter.exe..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    try {
        Invoke-WebRequest -Uri $ExeUrl -OutFile $ExePath -UseBasicParsing
        Write-Host "[OK] Download concluido: $ExePath" -ForegroundColor Green
    } catch {
        Write-Host "[ERRO] Falha no download: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# -------------------------------------------------------------------
# 2. Verificacao do Tesseract
# -------------------------------------------------------------------
Write-Host ""
Write-Host "[..] Verificando Tesseract OCR..." -ForegroundColor Cyan
$tesseract = Get-Command tesseract -ErrorAction SilentlyContinue
if ($tesseract) {
    $version = (& tesseract --version 2>&1 | Select-Object -First 1)
    Write-Host "[OK] Tesseract encontrado: $version" -ForegroundColor Green
} else {
    Write-Host "[ERRO] Tesseract nao encontrado no PATH." -ForegroundColor Red
    Write-Host "       Instale em: https://github.com/UB-Mannheim/tesseract/wiki" -ForegroundColor Yellow
    Write-Host "       Apos instalar, adicione a pasta de instalacao ao PATH do Windows." -ForegroundColor Yellow
    Write-Host "       Pasta tipica: C:\Program Files\Tesseract-OCR" -ForegroundColor Yellow
    exit 1
}

# -------------------------------------------------------------------
# 3. Verificacao do pdftohtml (vem com MiKTeX)
# -------------------------------------------------------------------
Write-Host ""
Write-Host "[..] Verificando pdftohtml (MiKTeX)..." -ForegroundColor Cyan
$pdftohtml = Get-Command pdftohtml -ErrorAction SilentlyContinue
if ($pdftohtml) {
    Write-Host "[OK] pdftohtml encontrado: $($pdftohtml.Source)" -ForegroundColor Green
} else {
    Write-Host "[ERRO] pdftohtml nao encontrado no PATH." -ForegroundColor Red
    Write-Host "       Instale o MiKTeX: https://miktex.org/download" -ForegroundColor Yellow
    exit 1
}

# -------------------------------------------------------------------
# Conclusao
# -------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host " Setup concluido. Use a task 'SAE Word Count' no VS Code" -ForegroundColor Green
Write-Host " ou execute manualmente: tools/count_words.ps1" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
