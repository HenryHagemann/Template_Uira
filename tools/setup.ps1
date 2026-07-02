<#
.SYNOPSIS
  Setup do ambiente SAE: PyAeroCounter (.exe), Tesseract OCR, MiKTeX, 
  Strawberry Perl, Inkscape, Lua e extensoes do VS Code.
.DESCRIPTION
  Executar UMA VEZ apos clonar o repositorio.
  Re-executar com -Force para forcar redownload do PyAeroCounter.
  Para instalacoes de sistema com PATH permanente, rode como Administrador.
#>

[CmdletBinding()]
param(
    [switch]$Force
)

# Forca o terminal a usar UTF-8 como backup, caso o sistema envie caracteres especiais
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- DESATIVA A BARRA DE PROGRESSO DO POWERSHELL ---
# Isso evita o Exit Code 1073741845 (crash de memoria no terminal do VS Code) 
# ao processar downloads de arquivos grandes.
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# User-Agent de navegador + TLS 1.2
$UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Codigos de saida do winget que significam "ja instalado"
$WingetOkCodes = @(0, -1978335189, -1978335135)

# -------------------------------------------------------------------
# Paths
# -------------------------------------------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DefaultTessPath = "C:\Program Files\Tesseract-OCR"
$PerlMsiUrl      = 'https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54221_64bit/strawberry-perl-5.42.2.1-64bit.msi'

# -------------------------------------------------------------------
# Helpers
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

function Test-WingetInstalled {
    param([string]$Id)
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { return $false }
    winget list --id $Id -e --accept-source-agreements 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [string]$Name
    )
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "    [!] winget nao disponivel. Pulei $Name." -ForegroundColor DarkGray
        return $false
    }
    if (Test-WingetInstalled -Id $Id) {
        Write-Host "[OK] $Name ja instalado (pulando)." -ForegroundColor Green
        return $true
    }
    Write-Host "[..] Instalando $Name via winget..." -ForegroundColor Cyan
    try {
        winget install --id $Id -e --silent --disable-interactivity `
            --accept-source-agreements --accept-package-agreements
        if ($WingetOkCodes -contains $LASTEXITCODE) {
            Write-Host "[OK] $Name instalado (ou ja presente)." -ForegroundColor Green
            return $true
        } else {
            Write-Host "[!] $Name retornou code $LASTEXITCODE." -ForegroundColor DarkGray
            return $false
        }
    } catch {
        Write-Host "    [!] winget falhou para ${Name}: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

function Add-ToPath {
    param([string]$Dir, [string]$Name)
    if (-not (Test-Path $Dir)) { return }
    try {
        $mp = [Environment]::GetEnvironmentVariable('Path','Machine')
        if ($mp -notlike "*$Dir*") {
            [Environment]::SetEnvironmentVariable('Path', "$mp;$Dir", 'Machine')
            Write-Host "[OK] $Name adicionado ao PATH do sistema (permanente)." -ForegroundColor Green
        }
    } catch {
        Write-Host "[!] Sem permissao para PATH do sistema. Gravando no PATH do usuario..." -ForegroundColor Yellow
        $up = [Environment]::GetEnvironmentVariable('Path','User')
        if ($up -notlike "*$Dir*") {
            [Environment]::SetEnvironmentVariable('Path', "$up;$Dir", 'User')
            Write-Host "[OK] $Name adicionado ao PATH do usuario (permanente)." -ForegroundColor Green
        }
    }
    if ($env:Path -notlike "*$Dir*") { $env:Path += ";$Dir" }
}

# -------------------------------------------------------------------
# 1. Verificacao / Instalacao do Python
# -------------------------------------------------------------------
Write-Host "`n=== 1. Verificacao do Python ===" -ForegroundColor Cyan

$PythonIsWorking = $false
$ActualPyVer = ""

$pyCmd = Get-Command python -ErrorAction SilentlyContinue

if ($pyCmd) {
    # O Windows cria atalhos falsos na pasta WindowsApps. Ignoramos para evitar falhas.
    if ($pyCmd.Source -match "WindowsApps") {
        Write-Host "    [!] Atalho da Microsoft Store detectado. Ignorando o falso Python..." -ForegroundColor DarkGray
    } else {
        try {
            $pyCheck = & "$($pyCmd.Source)" --version 2>&1 | Out-String
            if ($pyCheck -match "Python \d") {
                $PythonIsWorking = $true
                $ActualPyVer = $pyCheck.Trim()
            }
        } catch { }
    }
}

if (-not $PythonIsWorking) {
    Write-Host "    -> Python executavel real nao encontrado. Instalando via Winget..." -ForegroundColor Yellow
    winget install --id Python.Python.3.12 -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
    
    # Recarrega as variaveis de ambiente
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # Busca forçada do executável real nas pastas padrão
    Write-Host "    [..] Garantindo que o executavel real esteja no PATH..." -ForegroundColor Cyan
    $PythonCandidates = @(
        "$env:LOCALAPPDATA\Programs\Python\Python312",
        "C:\Program Files\Python312"
    )
    
    foreach ($cand in $PythonCandidates) {
        if (Test-Path (Join-Path $cand "python.exe")) {
            Add-ToPath -Dir $cand -Name "Python 3.12 (Base)"
            Add-ToPath -Dir (Join-Path $cand "Scripts") -Name "Python 3.12 (Scripts)"
            
            $env:Path = "$cand;" + (Join-Path $cand "Scripts") + ";$env:Path"
            $PythonIsWorking = $true
            break
        }
    }
} else {
    Write-Host "[OK] Python ja esta instalado e funcional: $ActualPyVer" -ForegroundColor Green
}

if (-not $PythonIsWorking) {
    Write-Host "[ERRO] Python nao foi instalado corretamente pelo Winget." -ForegroundColor Red
    Write-Host "       Vá no menu Iniciar, digite 'Aliases de execução do aplicativo' e desative o 'python.exe'." -ForegroundColor Yellow
    exit 1
}

Write-Host "    -> Instalando dependencias globais (Pillow, pytesseract)..." -ForegroundColor Cyan
# NOTA: O pdfminer3 FOI REMOVIDO DAQUI para forçar o uso da versão modificada que vem junto ao repositório!
python -m pip install --upgrade pip setuptools wheel | Out-Null
python -m pip install Pillow pytesseract | Out-Null


# -------------------------------------------------------------------
# 1b. PyAeroCounter (Via Repositorio Completo com pdfminer3 embutido)
# -------------------------------------------------------------------
Write-Host "`n=== 1b. PyAeroCounter (Ferramenta SAE) ===" -ForegroundColor Cyan
$GlobalToolDir = Join-Path $env:LOCALAPPDATA 'PyAeroCounter'
$ZipPath = Join-Path $GlobalToolDir 'PyAeroCounter.zip'
$RepoDir = Join-Path $GlobalToolDir 'PyAeroCounter-master'
$PyPath = Join-Path $RepoDir 'PyAeroCounter.py'
$BatPath = Join-Path $GlobalToolDir 'PyAeroCounter.bat'

if (-not (Test-Path $GlobalToolDir)) { New-Item -ItemType Directory -Force -Path $GlobalToolDir | Out-Null }

if ((Test-Path $PyPath) -and (Test-Path $BatPath) -and (-not $Force)) {
    Write-Host "[OK] PyAeroCounter ja esta instalado (pulando download)." -ForegroundColor Green
    Write-Host "     (Para forcar uma atualizacao/reinstalacao, rode: .\setup.ps1 -Force)" -ForegroundColor DarkGray
    Add-ToPath -Dir $GlobalToolDir -Name "PyAeroCounter"
} 
else {
    if ($Force) { Write-Host "    [!] Instalacao forcada detectada (-Force). Baixando novamente..." -ForegroundColor Yellow }
    
    Write-Host "    -> Baixando o repositorio completo (com as modificacoes da comissao)..." -ForegroundColor Cyan
    $RepoZipUrl = 'https://github.com/comissao-aerodesign/PyAeroCounter/archive/refs/heads/master.zip'
    
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($RepoZipUrl, $ZipPath)
    
    Write-Host "    -> Extraindo arquivos..." -ForegroundColor Cyan
    if (Test-Path $RepoDir) { Remove-Item -Path $RepoDir -Recurse -Force }
    Expand-Archive -Path $ZipPath -DestinationPath $GlobalToolDir -Force
    Remove-Item -Path $ZipPath -Force 
    
    Write-Host "    -> Criando atalho de execucao rapida..." -ForegroundColor Cyan
    # Como o bat entra na pasta do repo ("cd /d $RepoDir"), o Python usará o pdfminer3 local automaticamente
    $BatContent = "@echo off`r`ncd /d `"$RepoDir`"`r`npython `"$PyPath`" %*`r`ncd /d %cd%"
    Set-Content -Path $BatPath -Value $BatContent
    
    Add-ToPath -Dir $GlobalToolDir -Name "PyAeroCounter"
    Write-Host "[OK] Repositorio do PyAeroCounter configurado com sucesso!" -ForegroundColor Green
}

# -------------------------------------------------------------------
# 2. Verificacao / Instalacao do Tesseract
# -------------------------------------------------------------------
Write-Host ""
Write-Host "[..] Verificando Tesseract OCR..." -ForegroundColor Cyan

$tesseract = Get-Command tesseract -ErrorAction SilentlyContinue

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

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "    -> Instalando via winget (UB-Mannheim)..." -ForegroundColor Cyan
        try {
            winget install --id UB-Mannheim.TesseractOCR -e --silent --disable-interactivity `
                --accept-source-agreements --accept-package-agreements
            if ($WingetOkCodes -contains $LASTEXITCODE) { $installed = $true }
        } catch {
            Write-Host "    [!] winget falhou: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "    [!] winget nao disponivel." -ForegroundColor DarkGray
    }

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

    if ($installed -and (Test-Path (Join-Path $DefaultTessPath 'tesseract.exe'))) {
        Add-ToPath -Dir $DefaultTessPath -Name "Tesseract"
        $tesseract = Get-Command tesseract -ErrorAction SilentlyContinue
    }

    if ($tesseract) {
        $version = (& tesseract --version 2>&1 | Select-Object -First 1)
        Write-Host "[OK] Tesseract instalado: $version" -ForegroundColor Green
        Write-Host "     OBS: reinicie o terminal/VS Code para o PATH valer globalmente." -ForegroundColor DarkGray
    } else {
        Write-Host "[ERRO] Nao foi possivel instalar o Tesseract automaticamente." -ForegroundColor Red
        Write-Host "       Instale manualmente: https://github.com/UB-Mannheim/tesseract/wiki" -ForegroundColor Yellow
        exit 1
    }
}

# -------------------------------------------------------------------
# 3. MiKTeX e Inkscape (instalacao sequencial)
# -------------------------------------------------------------------
Write-Host ""
Write-Host "[..] Instalando dependencias de sistema..." -ForegroundColor Cyan
Install-WingetPackage -Id "MiKTeX.MiKTeX"     -Name "MiKTeX"   | Out-Null
Install-WingetPackage -Id "Inkscape.Inkscape" -Name "Inkscape" | Out-Null

# -------------------------------------------------------------------
# 3c. Configuracao e atualizacao do MiKTeX (sequencia oficial)
# -------------------------------------------------------------------
Write-Host ""
Write-Host "[..] Configurando e atualizando o MiKTeX..." -ForegroundColor Cyan

$MikCandidates = @(
    "C:\Program Files\MiKTeX\miktex\bin\x64",
    "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64",
    "C:\Program Files\MiKTeX 2.9\miktex\bin\x64"
)
$MikBin = $MikCandidates | Where-Object { Test-Path (Join-Path $_ 'miktex.exe') } | Select-Object -First 1
if ($MikBin) {
    Add-ToPath -Dir $MikBin -Name "MiKTeX"
    $env:Path = "$MikBin;$env:Path"
}

$miktex = Get-Command miktex -ErrorAction SilentlyContinue
if ($miktex) {
    $oldEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    $isAdmin = ([Security.Principal.WindowsPrincipal]`
        [Security.Principal.WindowsIdentity]::GetCurrent()`
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $isShared = $MikBin -like 'C:\Program Files\*'

    $scope = @()
    if ($isShared -and $isAdmin) {
        $scope = @('--admin')
        Write-Host "    (modo: shared/admin)" -ForegroundColor DarkGray
    } elseif ($isShared -and -not $isAdmin) {
        Write-Host "[!] MiKTeX e shared mas o terminal NAO e admin." -ForegroundColor Yellow
    } else {
        Write-Host "    (modo: per-user)" -ForegroundColor DarkGray
    }

    function Run-Mik {
        param([string]$Label, [string]$Exe, [string[]]$CmdArgs)
        Write-Host "    -> $Label" -ForegroundColor Cyan
        & $Exe @CmdArgs 2>&1 | ForEach-Object { Write-Host "       $_" -ForegroundColor DarkGray }
    }

    Run-Mik "Habilitando auto-install..."     'initexmf' (@('--set-config-value=[MPM]AutoInstall=1') + $scope)
    Run-Mik "Atualizando base de pacotes..."  'miktex'   ($scope + @('packages','update-package-database'))
    Run-Mik "Atualizando pacotes..."          'miktex'   ($scope + @('packages','update'))
    Run-Mik "Garantindo 'latexmk'..."         'miktex'   ($scope + @('packages','install','latexmk'))
    Run-Mik "Configurando fontmaps..."        'miktex'   ($scope + @('fontmaps','configure'))
    Run-Mik "Refresh fndb..."                 'miktex'   ($scope + @('fndb','refresh'))
    Run-Mik "Update fndb (initexmf)..."       'initexmf' ($scope + @('--update-fndb'))

    $texlua = Get-Command texlua -ErrorAction SilentlyContinue
    if ($texlua) {
        Write-Host "[OK] texlua disponivel: $($texlua.Source)" -ForegroundColor Green
        # Testa se o LuaFileSystem (lfs) carrega no texlua (necessario para lint-tex.lua)
        $lfsTest = & texlua -e "local ok = pcall(require, 'lfs'); io.write(ok and 'LFS_OK' or 'LFS_FAIL')" 2>&1 | Out-String
        if ($lfsTest -match 'LFS_OK') {
            Write-Host "[OK] LuaFileSystem (lfs) carregou corretamente no texlua." -ForegroundColor Green
        } else {
            Write-Host "[!] lfs nao carregou. O lint-tex.lua sera pulado." -ForegroundColor Yellow
            Write-Host "    O lfs e nativo no miktex-texlua; reinicie o terminal e tente de novo." -ForegroundColor DarkGray
        }
    } else {
        Write-Host "[!] texlua nao encontrado no PATH. Reinicie o terminal." -ForegroundColor Yellow
    }

    $ErrorActionPreference = $oldEAP

    $lmk = Get-Command latexmk -ErrorAction SilentlyContinue
    if ($lmk) {
        Write-Host "[OK] latexmk garantido no PATH." -ForegroundColor Green
    } else {
        Write-Host "[!] latexmk instalado; reinicie o terminal para ele entrar no PATH." -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] CLI 'miktex' nao encontrada. Reinicie o terminal e rode manualmente a sequencia." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------
# 3a. Strawberry Perl
# -------------------------------------------------------------------
Write-Host ""
Write-Host "[..] Verificando Strawberry Perl..." -ForegroundColor Cyan
if (Get-Command perl -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Perl ja presente: $((& perl -v) -split "`n" | Select-String 'This is perl')" -ForegroundColor Green
} else {
    $perlOk = Install-WingetPackage -Id "StrawberryPerl.StrawberryPerl" -Name "Strawberry Perl"

    if (-not $perlOk -and -not (Get-Command perl -ErrorAction SilentlyContinue)) {
        Write-Host "    -> winget falhou. Baixando MSI direto..." -ForegroundColor Cyan
        $PerlMsi = Join-Path $env:TEMP 'strawberry-perl.msi'
        try {
            Get-RemoteFile -Url $PerlMsiUrl -OutFile $PerlMsi
            Write-Host "    -> Instalando MSI silenciosamente..." -ForegroundColor Cyan
            $p = Start-Process msiexec.exe -ArgumentList "/i `"$PerlMsi`" /qb /norestart" -Wait -PassThru
            if ($p.ExitCode -eq 0) {
                Write-Host "[OK] Strawberry Perl instalado via MSI." -ForegroundColor Green
            } else {
                Write-Host "[!] msiexec retornou code $($p.ExitCode)." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "[ERRO] Falha ao baixar/instalar o Perl." -ForegroundColor Red
        }
    }
}

$PerlBins = @("C:\Strawberry\perl\bin", "C:\Strawberry\c\bin", "C:\Strawberry\perl\site\bin")
foreach ($pb in $PerlBins) { if (Test-Path $pb) { Add-ToPath -Dir $pb -Name "Strawberry Perl" } }

# -------------------------------------------------------------------
# 3b. Garante Inkscape no PATH
# -------------------------------------------------------------------
Write-Host ""
Write-Host "[..] Verificando Inkscape no PATH..." -ForegroundColor Cyan
if (-not (Get-Command inkscape -ErrorAction SilentlyContinue)) {
    $InkCandidates = @(
        "C:\Program Files\Inkscape\bin",
        "C:\Program Files (x86)\Inkscape\bin",
        "C:\Program Files\Inkscape",
        "C:\Program Files (x86)\Inkscape"
    )
    $InkBin = $InkCandidates | Where-Object { Test-Path (Join-Path $_ 'inkscape.exe') } | Select-Object -First 1
    if ($InkBin) {
        Add-ToPath -Dir $InkBin -Name "Inkscape"
    } else {
        Write-Host "[!] inkscape.exe nao localizado nos caminhos padrao." -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] Inkscape ja esta no PATH." -ForegroundColor Green
}

# -------------------------------------------------------------------
# 4. Extensoes do VS Code
# -------------------------------------------------------------------
Write-Host ""
Write-Host "[..] Instalando extensoes do VS Code..." -ForegroundColor Cyan
if (Get-Command code -ErrorAction SilentlyContinue) {
    $extensions = @(
        "james-yu.latex-workshop",
        "gruntfuggly.triggertaskonsave",
        "ms-vsliveshare.vsliveshare",
        "eamodio.gitlens"
    )
    foreach ($ext in $extensions) {
        Write-Host "    -> $ext" -ForegroundColor Cyan
        code --install-extension $ext --force
    }
    Write-Host "[OK] Extensoes processadas." -ForegroundColor Green
} else {
    Write-Host "[!] Comando 'code' nao encontrado no PATH. Pulei as extensoes." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------
# Conclusao
# -------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host " Setup concluido. Reinicie o terminal/VS Code para o PATH"       -ForegroundColor Green
Write-Host " valer globalmente para todas as ferramentas."                   -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green