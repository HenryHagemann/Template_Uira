<#
.SYNOPSIS
  Wrapper do PyAeroCounter para contagem de palavras conforme regulamento SAE.

.DESCRIPTION
  O PyAeroCounter.exe tem comportamento hardcoded:
    - Espera o arquivo de entrada com nome 'pdffile.pdf' ao lado do .exe
    - Gera 'logfile.txt' e pasta de imagens no CWD (pasta do .exe)
    - Flags -i/-o nao controlam a extracao de figuras via pdftohtml

  Para reproduzir fielmente o fluxo manual que funciona, este wrapper:
    1. Copia main.pdf -> tools/pyaerocounter/pdffile.pdf
    2. Muda CWD para tools/pyaerocounter/
    3. Executa o .exe sem flags
    4. Copia logfile.txt resultante para build/wordcount/
    5. Limpa arquivos temporarios da pasta do .exe
#>

[CmdletBinding()]
param(
    [string]$PdfPath = "main.pdf"
)

$ErrorActionPreference = "Stop"

# --- Resolucao de paths ---
$RepoRoot      = Split-Path -Parent $PSScriptRoot
$ExeDir        = Join-Path $PSScriptRoot "pyaerocounter"
$ExePath       = Join-Path $ExeDir "PyAeroCounter.exe"
$PdfSource     = Join-Path $RepoRoot $PdfPath
$PdfTarget     = Join-Path $ExeDir "pdffile.pdf"
$LogSource     = Join-Path $ExeDir "logfile.txt"
$OutDir        = Join-Path $RepoRoot "build\wordcount"
$LogTarget     = Join-Path $OutDir "logfile.txt"

# --- Validacoes ---
if (-not (Test-Path $ExePath)) {
    Write-Host "[ERRO] PyAeroCounter.exe nao encontrado em: $ExePath" -ForegroundColor Red
    Write-Host "       Rode a task 'SAE Word Count: Setup' primeiro." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $PdfSource)) {
    Write-Host "[ERRO] PDF nao encontrado: $PdfSource" -ForegroundColor Red
    Write-Host "       Compile o relatorio antes de contar palavras." -ForegroundColor Yellow
    exit 1
}

# --- Preparacao ---
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

# Limpa estado anterior da pasta do .exe (figuras antigas, logfile, etc)
Get-ChildItem -Path $ExeDir -Exclude "PyAeroCounter.exe" -Force | ForEach-Object {
    Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "[..] Copiando $PdfPath -> pdffile.pdf na pasta do .exe..." -ForegroundColor Cyan
Copy-Item -Path $PdfSource -Destination $PdfTarget -Force

# --- Execucao ---
Write-Host "[..] Executando PyAeroCounter (pode demorar alguns minutos)..." -ForegroundColor Cyan
Write-Host "     CWD: $ExeDir" -ForegroundColor DarkGray

Push-Location $ExeDir
try {
    & $ExePath
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    Write-Host "[AVISO] PyAeroCounter retornou exit code $exitCode" -ForegroundColor Yellow
}

# --- Coleta de resultado ---
if (-not (Test-Path $LogSource)) {
    Write-Host "[ERRO] logfile.txt nao foi gerado. Algo falhou na execucao." -ForegroundColor Red
    exit 1
}

Copy-Item -Path $LogSource -Destination $LogTarget -Force
Write-Host "[OK] logfile.txt copiado para: $LogTarget" -ForegroundColor Green

# Opcional: preserva pasta de imagens extraidas para inspecao
$ImagesSource = Join-Path $ExeDir "images"
if (Test-Path $ImagesSource) {
    $ImagesTarget = Join-Path $OutDir "images"
    if (Test-Path $ImagesTarget) { Remove-Item $ImagesTarget -Recurse -Force }
    Copy-Item -Path $ImagesSource -Destination $ImagesTarget -Recurse -Force
    Write-Host "[OK] Pasta de imagens copiada para: $ImagesTarget" -ForegroundColor Green
}

# --- Limpeza ---
Remove-Item $PdfTarget -Force -ErrorAction SilentlyContinue

# --- Exibicao do resultado ---
Write-Host ""
Write-Host "--- Conteudo do logfile.txt ---" -ForegroundColor Cyan
Get-Content $LogTarget
