# Ferramentas auxiliares — `tools/`

Esta pasta contém scripts e arquivos de configuração das ferramentas auxiliares do template:

- **Contagem oficial de palavras** (padrão SAE) via PyAeroCounter;
- **Linter LaTeX** que detecta problemas comuns ao salvar.

Todos os comandos abaixo assumem que o VS Code está aberto na **raiz do repositório** (a pasta que contém `main.tex`), não dentro de `tools/`.

---

# Sumário

- [1. Visão geral](#1-visão-geral)
- [2. Pré-requisitos](#2-pré-requisitos)
- [3. Contagem de palavras (PyAeroCounter)](#3-contagem-de-palavras-pyaerocounter)
- [4. Linter LaTeX](#4-linter-latex)
- [5. Arquivos de configuração](#5-arquivos-de-configuração)
- [6. Troubleshooting](#6-troubleshooting)

---

# 1. Visão geral

```text
tools/
├── README.md                    -> este arquivo
├── count_words.ps1              -> dispara o PyAeroCounter
├── setup_pyaerocounter.ps1      -> baixa e instala o PyAeroCounter
├── lint_tex.lua                 -> linter LaTeX (texlua)
├── forbidden_words.txt          -> palavras a evitar no relatório
├── markers.txt                  -> marcadores de pendência (TODO, FIXME, etc.)
└── PyAeroCounter.exe            -> executável baixado pelo setup (NÃO versionado)
```

Resumo do papel de cada componente:

| Componente | Tipo | Disparado por |
|------------|------|---------------|
| `setup_pyaerocounter.ps1` | Script de instalação | Task `SAE Word Count: Setup` |
| `count_words.ps1` | Script de execução | Task `SAE Word Count` |
| `lint_tex.lua` | Linter | Task `LaTeX Lint` (automática ao salvar e ao abrir) |
| `forbidden_words.txt` | Configuração | Lido por `lint_tex.lua` |
| `markers.txt` | Configuração | Lido por `lint_tex.lua` |

---

# 2. Pré-requisitos

**Para o lint:**

- `texlua` — interpretador Lua incluído nas distribuições LaTeX (MiKTeX, TeX Live). Não precisa instalar separado.
- Extensão **Trigger Task on Save** no VS Code, para o lint disparar ao salvar.

**Para a contagem de palavras:**

- **PowerShell** — já vem no Windows;
- **Tesseract OCR** — necessário para o PyAeroCounter funcionar (ele faz OCR no PDF);
- **MiKTeX** ou **TeX Live** instalado;
- Conexão com a internet (apenas na primeira execução do setup).

Para instalar o Tesseract no Windows:

```text
https://github.com/UB-Mannheim/tesseract/wiki
```

Durante a instalação, marque a opção que adiciona o Tesseract ao `PATH`. Depois, abra um terminal novo e confira:

```powershell
tesseract --version
```

Se aparecer a versão, está OK. Se aparecer erro, refaça a instalação marcando a opção de PATH.

---

# 3. Contagem de palavras (PyAeroCounter)

O **PyAeroCounter** é a ferramenta oficial da SAE para contagem de palavras do relatório. Ele aplica as regras específicas do regulamento (ignora legendas, equações, tabelas, etc.) usando OCR sobre o PDF compilado.

## 3.1. Setup (uma vez por máquina)

Após clonar o repositório, execute uma única vez:

```text
Ctrl + Shift + P > Tasks: Run Task > SAE Word Count: Setup
```

O que essa task faz:

1. Verifica se MiKTeX/TeX Live está instalado;
2. Verifica se Tesseract OCR está instalado e no `PATH`;
3. Baixa o `PyAeroCounter.exe` na pasta `tools/`;
4. Mostra mensagens de sucesso ou erro no terminal.

> O `PyAeroCounter.exe` **não é versionado** no Git (está no `.gitignore`). Cada integrante baixa o seu localmente via setup.

Se o setup falhar, veja [Troubleshooting](#6-troubleshooting).

## 3.2. Rodar a contagem

Pré-condição: o `main.pdf` precisa estar compilado e atualizado.

```text
Ctrl + Shift + P > Tasks: Run Task > SAE Word Count
```

O que acontece:

1. O script `count_words.ps1` é executado;
2. Ele chama `PyAeroCounter.exe` passando o `main.pdf` como entrada;
3. O PyAeroCounter faz OCR no PDF (demora **vários minutos**, é normal);
4. O resultado da contagem aparece no terminal.

> **Aviso de tempo**: a contagem demora de 3 a 10 minutos dependendo do tamanho do PDF e da máquina. Não cancele no meio. Use enquanto faz outra coisa.

## 3.3. Quando rodar

- Antes de submeter o relatório oficialmente;
- Periodicamente, para acompanhar se a equipe está perto do limite de palavras;
- **Não rode** a cada edição — é caro em tempo e não muda nada que o lint pegaria primeiro.

---

# 4. Linter LaTeX

O linter é um script Lua (`lint_tex.lua`) que varre todos os arquivos `.tex` do projeto e reporta:

- **Palavras proibidas** (informais, gírias, termos a evitar) — definidas em `forbidden_words.txt`;
- **Marcadores de pendência** (TODO, FIXME, etc.) — definidos em `markers.txt`;
- **Outros problemas** detectados pelo script (verifique `lint_tex.lua` para a lista completa).

## 4.1. Como roda

Três formas:

1. **Automaticamente ao abrir o projeto** — a task `LaTeX Lint` tem `runOn: folderOpen`;
2. **Automaticamente ao salvar qualquer `.tex`** — graças à extensão `triggerTaskOnSave`, configurada em `settings.json`;
3. **Manualmente** via paleta de comandos:

```text
Ctrl + Shift + P > Tasks: Run Task > LaTeX Lint
```

## 4.2. Onde ver os resultados

Os avisos aparecem no painel **Problems** do VS Code:

```text
View > Problems   (ou Ctrl + Shift + M)
```

Cada aviso traz arquivo, linha, coluna, severidade (`warning`, `info`, `error`) e mensagem. Clicando, o VS Code abre o arquivo no ponto exato.

## 4.3. Severidades

| Severidade | Significado | O que fazer |
|------------|-------------|-------------|
| `error` | Problema grave (ex.: erro de sintaxe detectável). | Corrija antes de fazer commit. |
| `warning` | Provável problema (ex.: palavra proibida). | Revise. Corrija se aplicável. |
| `info` | Aviso informativo (ex.: marcador TODO). | Não bloqueia, mas resolva antes da entrega final. |

## 4.4. Por que o lint é importante

Antes do lint, era comum o relatório chegar à entrega com:

- palavras informais ("coisa", "tipo", "etc.");
- marcadores `TODO` esquecidos no meio do texto;
- inconsistências de formatação.

O lint pega isso automaticamente toda vez que você salva, sem precisar lembrar de rodar nada.

---

# 5. Arquivos de configuração

## 5.1. `forbidden_words.txt`

Lista de palavras que o lint deve sinalizar quando aparecerem em arquivos `.tex`.

**Formato**: uma palavra por linha. Comentários começam com `#`.

Exemplo:

```text
# Palavras informais
coisa
tipo
muito
```

**Para adicionar uma palavra:**

1. Abra `tools/forbidden_words.txt`;
2. Adicione a palavra em uma nova linha;
3. Salve. O lint usa a versão mais recente do arquivo na próxima execução.

**Para remover uma palavra:**

1. Apague ou comente a linha (com `#` no começo);
2. Salve.

> Mudanças no `forbidden_words.txt` afetam o relatório inteiro. Combine com a equipe antes de adicionar palavras polêmicas.

## 5.2. `markers.txt`

Lista de marcadores que o lint deve sinalizar como pendência.

**Formato**: um marcador por linha. Comentários começam com `#`.

Exemplo:

```text
TODO
FIXME
XXX
REVISAR
```

Esses marcadores são úteis durante a escrita: quando você sabe que precisa voltar em um trecho mais tarde, escreve `% TODO: revisar este parágrafo` e o lint te lembra disso a cada salvamento.

**Antes da entrega final**, o painel `Problems` deve estar sem nenhum aviso de marcador.

## 5.3. `lint_tex.lua`

O script do linter propriamente dito.

Não precisa mexer no dia a dia. Modifique apenas se quiser:

- adicionar novas regras de verificação;
- mudar a severidade de algum aviso;
- alterar a formatação da saída.

> Mudanças no `lint_tex.lua` precisam manter o formato de saída esperado pelo `problemMatcher` do VS Code:
>
> ```text
> arquivo:linha:coluna: severity: mensagem
> ```
>
> Se quebrar esse formato, os avisos param de aparecer no painel `Problems`.

## 5.4. `count_words.ps1` e `setup_pyaerocounter.ps1`

Scripts PowerShell que orquestram o PyAeroCounter. Não precisa abrir esses arquivos no dia a dia — eles são chamados pelas tasks do VS Code.

Modifique apenas se:

- a URL de download do `PyAeroCounter.exe` mudar (em `setup_pyaerocounter.ps1`);
- você quiser passar argumentos diferentes para o `PyAeroCounter.exe` (em `count_words.ps1`).

---

# 6. Troubleshooting

## 6.1. Lint não está rodando ao salvar

**Causa provável**: a extensão `triggerTaskOnSave` não está instalada.

**Solução**:

1. Vá em Extensions (`Ctrl + Shift + X`);
2. Procure por `Trigger Task on Save`;
3. Instale a extensão `Gruntfuggly.triggertaskonsave`;
4. Salve um `.tex` qualquer e veja se o lint dispara.

## 6.2. Lint roda, mas não aparece nada no painel `Problems`

**Causa provável 1**: o `lint_tex.lua` está mudando o formato de saída.

**Solução**: confira que cada aviso sai no formato:

```text
arquivo:linha:coluna: severity: mensagem
```

**Causa provável 2**: `texlua` não está no `PATH`.

**Solução**: abra um terminal e rode:

```powershell
texlua -v
```

Se não funcionar, reinstale MiKTeX/TeX Live marcando a opção de adicionar ao `PATH`.

## 6.3. Setup do PyAeroCounter falha

**Erro: "Tesseract não encontrado"**

Instale o Tesseract OCR e adicione ao `PATH`. Veja [Seção 2](#2-pré-requisitos).

**Erro: "MiKTeX não encontrado"**

Instale MiKTeX ou TeX Live.

**Erro: "Falha ao baixar PyAeroCounter.exe"**

- Verifique sua conexão com a internet;
- Verifique se algum antivírus está bloqueando o download;
- Confira a URL dentro de `setup_pyaerocounter.ps1` — pode ter mudado.

## 6.4. Contagem de palavras dá número muito diferente do esperado

**Causa provável**: o PDF está desatualizado ou compilado com erro.

**Solução**:

1. Recompile o `main.tex` com `Ctrl + S`;
2. Confira que o `main.pdf` na raiz é o mais recente;
3. Rode a task `SAE Word Count` de novo.

## 6.5. Task `SAE Word Count` dá "Execution Policy" no PowerShell

**Causa**: política de execução do PowerShell bloqueando scripts.

**Solução**: a task já passa `-ExecutionPolicy Bypass` como argumento, então isso **não deveria** acontecer. Se aconteceu, abra um PowerShell como administrador e rode:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## 6.6. Quero rodar o lint só em um arquivo específico

O `lint_tex.lua` atual roda em todos os `.tex` do projeto. Não há flag para limitar a um arquivo.

Se for necessário, modifique o script para aceitar um argumento de caminho — mas para o uso normal, rodar em todos é rápido o suficiente.
