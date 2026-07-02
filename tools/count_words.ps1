<#
.SYNOPSIS
  Wrapper do PyAeroCounter para contagem de palavras conforme regulamento SAE.

.DESCRIPTION
  Envia o PDF para a pasta de instalacao global, executa, e traz os logs
  de volta para manter o repositorio do projeto limpo.
#>

[CmdletBinding()]
param(
    [string]$PdfPath = "main.pdf"
)

$ErrorActionPreference = "Stop"

# --- Resolucao de paths ---
$RepoRoot      = Split-Path -Parent $PSScriptRoot

# Paths da instalacao global
$GlobalToolDir = Join-Path $env:LOCALAPPDATA "PyAeroCounter"
$RepoDir       = Join-Path $GlobalToolDir "PyAeroCounter-master"
$BatPath       = Join-Path $GlobalToolDir "PyAeroCounter.bat"

# Paths do projeto local
$PdfSource     = Join-Path $RepoRoot $PdfPath
$OutDir        = Join-Path $RepoRoot "wordcount"

# O PyAeroCounter FORCA o diretorio de trabalho a ser a pasta dele.
# Entao temos que jogar o PDF diretamente na pasta do script global.
$PdfTarget     = Join-Path $RepoDir "pdffile.pdf"

# Arquivos de saida gerados pelo script que devem ser preservados
$OutputFiles = @(
    "logfile.txt",
    "wordsfile.txt",
    "mathmodewords.txt",
    "nonwordsfile.txt",
    "file_strings_from_images.txt"
)

# --- Validacoes ---
if (-not (Test-Path $BatPath)) {
    Write-Host "[ERRO] PyAeroCounter nao encontrado em: $BatPath" -ForegroundColor Red
    Write-Host "       Rode a task de Setup de dependencias primeiro para instalar." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $PdfSource)) {
    Write-Host "[ERRO] PDF nao encontrado: $PdfSource" -ForegroundColor Red
    Write-Host "       Compile o relatorio antes de contar palavras." -ForegroundColor Yellow
    exit 1
}

# --- Preparacao do Ambiente ---
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

Write-Host "[..] Limpando residuos de execucoes anteriores..." -ForegroundColor Cyan
Remove-Item $PdfTarget -Force -ErrorAction SilentlyContinue
foreach ($file in $OutputFiles) { Remove-Item (Join-Path $RepoDir $file) -Force -ErrorAction SilentlyContinue }
if (Test-Path (Join-Path $RepoDir "images")) { Remove-Item (Join-Path $RepoDir "images") -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path (Join-Path $RepoDir "pdffile")) { Remove-Item (Join-Path $RepoDir "pdffile") -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host "[..] Enviando PDF para processamento interno do PyAeroCounter..." -ForegroundColor Cyan
Copy-Item -Path $PdfSource -Destination $PdfTarget -Force

# --- Execucao ---
Write-Host "[..] Executando PyAeroCounter (isso pode demorar alguns minutos)..." -ForegroundColor Cyan

# Roda o .bat (ele cuida de chamar o Python corretamente na pasta certa)
& $BatPath
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    Write-Host "[AVISO] PyAeroCounter retornou exit code $exitCode" -ForegroundColor Yellow
}

# --- Coleta de resultados ---
$LogSource = Join-Path $RepoDir "logfile.txt"
if (-not (Test-Path $LogSource)) {
    Write-Host "[ERRO] logfile.txt nao foi gerado. O script falhou silenciosamente." -ForegroundColor Red
    exit 1
}

Write-Host "[..] Resgatando resultados e organizando em wordcount/..." -ForegroundColor Cyan

# Traz os arquivos de texto
foreach ($file in $OutputFiles) {
    $src = Join-Path $RepoDir $file
    if (Test-Path $src) {
        Move-Item -Path $src -Destination (Join-Path $OutDir $file) -Force
        Write-Host "[OK] $file salvo." -ForegroundColor Green
    }
}

# Traz a pasta de imagens
$ImagesCandidates = @("pdffile", "images")
foreach ($imgFolder in $ImagesCandidates) {
    $ImagesSource = Join-Path $RepoDir $imgFolder
    if (Test-Path $ImagesSource) {
        $ImagesTarget = Join-Path $OutDir "images"
        if (Test-Path $ImagesTarget) { Remove-Item $ImagesTarget -Recurse -Force }
        Move-Item -Path $ImagesSource -Destination $ImagesTarget -Force
        Write-Host "[OK] Pasta de imagens salva." -ForegroundColor Green
        break
    }
}

# --- Limpeza Final ---
Remove-Item $PdfTarget -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Ambiente temporario limpo." -ForegroundColor Green

# --- Exibicao do resultado ---
Write-Host ""
Write-Host "--- Conteudo do logfile.txt ---" -ForegroundColor Cyan
Get-Content (Join-Path $OutDir "logfile.txt")
