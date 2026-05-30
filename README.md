# Relatório Técnico — Uirá Aerodesign

Este repositório contém o template LaTeX do relatório técnico da equipe **Uirá Aerodesign**.

> **Atenção:** este repositório é um **template**. Ele deve ser usado como base para criar novos relatórios. **Não edite este repositório diretamente para produzir o relatório oficial da equipe**, a menos que isso tenha sido combinado previamente.

A ideia é que qualquer integrante consiga:

- Criar um novo projeto de relatório a partir deste template;
- Alterar as informações básicas do relatório;
- Escrever capítulos;
- Inserir figuras, tabelas e referências;
- Compilar o PDF no VS Code;
- Usar Git e GitHub para versionamento;
- Trabalhar em equipe com Live Share;
- Usar o VS Code de forma parecida com o Overleaf;
- Contar palavras pelo padrão oficial SAE;
- Detectar erros comuns de LaTeX automaticamente ao salvar.

Exemplo de uso correto:

```text
Template-Uira       = modelo base
Relatorio-Uira-2026 = projeto real de trabalho
Relatorio-Uira-2027 = outro projeto real de trabalho
```

A lógica correta é:

1. Usar este repositório como **base**;
2. Criar um **novo repositório** para o relatório real;
3. Trabalhar colaborativamente nesse novo repositório;
4. Manter o template limpo e reutilizável.

---

## Sumário

1. [Estrutura do projeto](#1-estrutura-do-projeto)
2. [Pré-requisitos](#2-pré-requisitos)
3. [Arquivos e pastas importantes](#3-arquivos-e-pastas-importantes)
4. [O que normalmente deve ser editado](#4-o-que-normalmente-deve-ser-editado)
5. [Como compilar o relatório](#5-como-compilar-o-relatório)
6. [LaTeX Workshop no VS Code](#6-latex-workshop-no-vs-code)
7. [Tasks do VS Code](#7-tasks-do-vs-code)
8. [Ferramentas auxiliares (tools/)](#8-ferramentas-auxiliares-tools)
9. [Git e GitHub](#9-git-e-github)
10. [Como criar um novo projeto a partir do template](#10-como-criar-um-novo-projeto-a-partir-do-template)
11. [Fluxo de trabalho com Git](#11-fluxo-de-trabalho-com-git)
12. [Branches](#12-branches)
13. [Conflitos](#13-conflitos)
14. [Live Share](#14-live-share)
15. [Checklist antes de fazer push](#15-checklist-antes-de-fazer-push)
16. [Fluxo mínimo para novos integrantes](#16-fluxo-mínimo-para-novos-integrantes)

---

## 1. Estrutura do projeto

A estrutura principal do projeto é:

```text
Relatorio/
├── .gitignore
├── .vscode/
│   ├── extensions.json
│   ├── settings.json
│   └── tasks.json
├── build/
├── capitulos/
├── imagens/
├── logos/
├── sec/
├── tools/
│   ├── README.md
│   ├── count_words.ps1
│   ├── forbidden_words.txt
│   ├── lint_tex.lua
│   ├── markers.txt
│   └── setup_pyaerocounter.ps1
├── main.tex
├── referencias.bib
├── uira_template.sty
└── README.md
```

Resumo:

```text
main.tex            -> arquivo principal do relatório
uira_template.sty   -> arquivo de estilo/formatação do template
referencias.bib     -> referências bibliográficas
capitulos/          -> capítulos do relatório
imagens/            -> imagens usadas no corpo do relatório
logos/              -> logos e imagens institucionais
sec/                -> arquivos estruturais do relatório
tools/              -> scripts auxiliares (lint, word count)
.vscode/            -> configurações do VS Code (tasks, settings, extensões)
build/              -> arquivos gerados automaticamente na compilação
.gitignore          -> define arquivos que não devem ir para o Git
README.md           -> instruções gerais do projeto
```

---

### 2.1. Programas (instale primeiro, nesta ordem)

1. **[Git](https://git-scm.com/downloads)** — controle de versão.

2. **[Strawberry Perl](https://strawberryperl.com/)** — necessário para o `latexmk` (motor de compilação usado pelo template).
   O MiKTeX **não inclui Perl**. Sem ele, a compilação não funciona.

3. **[MiKTeX](https://miktex.org/download)** — distribuição LaTeX recomendada no Windows.
   Durante a instalação, deixe a opção **"Install missing packages on the fly"** marcada como **Yes**.

4. **[Inkscape](https://inkscape.org/release/)** — necessário para que o LaTeX consiga incluir imagens em **SVG** (via pacote `svg`, que converte SVG para PDF na hora da compilação).
   Sem o Inkscape no `PATH`, qualquer `\includesvg{...}` vai quebrar a compilação.
   Durante a instalação, deixe marcada a opção **"Add Inkscape to system PATH for all users"** (ou equivalente). Para conferir depois, abra um terminal novo e rode:

   ```powershell
   inkscape --version
   ```

   Se aparecer a versão, está OK. Se der "comando não reconhecido", adicione manualmente a pasta de instalação do Inkscape (ex.: `C:\Program Files\Inkscape\bin`) ao `PATH` do Windows.

> Reinicie o computador (ou pelo menos feche todos os terminais) depois de instalar Git, MiKTeX, Perl e Inkscape, para garantir que o `PATH` foi atualizado.

### 2.2. VS Code (instale depois dos programas acima)

5. **[Visual Studio Code](https://code.visualstudio.com/Download)** — editor.

### 2.3. Extensões do VS Code (instale por último)

Ao abrir a pasta do projeto pela primeira vez, o VS Code vai sugerir automaticamente as extensões recomendadas (definidas em `.vscode/extensions.json`). **Aceite a instalação.**

Se quiser instalar manualmente:

6. **[LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)** — compilação e visualização do PDF.
7. **[Trigger Task on Save](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.triggertaskonsave)** — dispara o lint automático ao salvar `.tex`.
8. **[Live Share](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare)** — colaboração em tempo real (ver [Seção 14](#14-live-share)).


## 3. Arquivos e pastas importantes

### 3.1. `main.tex`

Este é o arquivo principal do relatório.

É nele que ficam as informações gerais da equipe e do documento, como:

- nome da instituição;
- nome da competição;
- nome da equipe;
- orientador;
- data do relatório;
- número da equipe;
- e-mail;
- lista de alunos;
- caminhos das logos;
- chamadas dos arquivos estruturais.

Na maioria dos casos, quem for usar o template só precisa alterar a parte de informações da equipe:

```latex
% INFORMACAO DA EQUIPE
\instituicao{Universidade Federal de Itajubá - UNIFEI}
\competicao{XXVIII Competição SAE Brasil Aerodesign - 2026}
\equipe{Uirá Aerodesign}
\disciplina{Relatório Técnico Uirá Aerodesign}
\orientador{Prof. Dr. Yohan Díaz}
\datarelatorio{01 de Janeiro de 2026}
\numeroEquipe{001}
\email{uira@unifei.edu.br}

\alunos{
Daniel Godoy\\
Fábio Menezes\\
Gabriel Machado\\
Gabriel Ribeiro\\
Gabriela Fincatti\\
Henrique Goulart\\
Henry Matheus Hagemann\\
Lucas Zacchi\\
Luís Henrique Laurindo\\
Matheus Morth\\
Rafael Neves\\
Renan Barbosa\\
Vinícius Montanari\\
Yasmim Vilas Boas\\
Yudi Ribeiro\\
}
```

Também podem ser alterados os caminhos das logos, caso os arquivos mudem de nome:

```latex
\logoaero{./logos/logo_ctec_aero.png}
\logoequipe{./logos/Uira_simbolo.png}
\logounifei{./logos/simbolo_unifei.png}
\logocapa{./logos/Uira_Logo.png}
```

Não é recomendado alterar o restante do `main.tex` sem necessidade.

### 3.2. `capitulos/`

A pasta `capitulos/` contém os capítulos do relatório.

Cada capítulo deve ficar em um arquivo separado.

Exemplo:

```text
capitulos/
├── introducao.tex
├── requisitos.tex
├── aerodinamica.tex
├── estabilidade.tex
├── desempenho.tex
└── conclusao.tex
```

Exemplo de capítulo:

```latex
\chapter{Introdução}

Este capítulo apresenta o contexto geral do projeto e os objetivos da equipe.
```

O arquivo `capitulos/introducao.tex` que vem no template é um exemplo base — use-o como referência de formatação.

### 3.3. `sec/`

A pasta `sec/` contém arquivos estruturais do relatório.

Ela pode possuir arquivos como:

```text
sec/
├── simbolos.tex
├── inputs.tex
├── documento.tex
└── outputs.tex
```

Esses arquivos são chamados pelo `main.tex` nesta ordem:

```latex
% LISTA DE SÍMBOLOS
\include{sec/simbolos}

% LISTA DE INPUTS
\include{sec/inputs}

% TEXTO TÉCNICO
\include{sec/documento}

% LISTA DE OUTPUTS
\include{sec/outputs}
```

O arquivo mais importante dessa pasta é:

```text
sec/documento.tex
```

Ele define a ordem dos capítulos do relatório.

Exemplo:

```latex
\include{capitulos/introducao.tex}
\include{capitulos/requisitos.tex}
\include{capitulos/aerodinamica.tex}
\include{capitulos/desempenho.tex}
\include{capitulos/conclusao.tex}
```

Se quiser adicionar, remover ou mudar a ordem dos capítulos, normalmente você deve alterar:

```text
sec/documento.tex
```

**Não esqueça de colocar o `.tex` no final do `\include`.**

Correto:

```latex
\include{capitulos/introducao.tex}
```

Errado:

```latex
\include{capitulos/introducao}
```

### 3.4. `imagens/`

A pasta `imagens/` é dedicada às imagens usadas no corpo do relatório.

Coloque aqui imagens como:

- gráficos;
- diagramas;
- fotos da aeronave;
- desenhos;
- resultados de simulação;
- esquemas técnicos.

Exemplo:

```text
imagens/
├── aeronave.png
├── grafico_carga.png
├── asa.pdf
└── simulacao_cfd.png
```

### 3.5. `logos/`

A pasta `logos/` contém as imagens usadas na identidade visual do relatório.

Exemplo:

```text
logos/
├── logo_ctec_aero.png
├── Uira_simbolo.png
├── simbolo_unifei.png
└── Uira_Logo.png
```

Se trocar alguma logo, confira se o caminho no `main.tex` também foi atualizado.

```latex
\logoequipe{./logos/Uira_simbolo.png}
```

### 3.6. `referencias.bib`

Arquivo onde ficam as referências bibliográficas do relatório.

Exemplo:

```bibtex
@book{anderson2017,
  author    = {John D. Anderson},
  title     = {Fundamentals of Aerodynamics},
  year      = {2017},
  publisher = {McGraw-Hill}
}
```

### 3.7. `uira_template.sty`

Arquivo de estilo do template.

Ele controla a formatação geral do relatório, como:

- capa;
- cabeçalho;
- rodapé;
- margens;
- fontes;
- espaçamentos;
- estilos de títulos;
- comandos personalizados.

**Não é recomendado mexer nesse arquivo sem necessidade.**

Se algo visual do template precisar ser alterado, faça isso com cuidado, porque mudanças nesse arquivo afetam o relatório inteiro.

### 3.8. `.vscode/`

Pasta de configuração do Visual Studio Code, versionada no Git.

Contém três arquivos:

- `settings.json` — configurações do LaTeX Workshop (recipe, viewer, lint automático ao salvar, limpeza);
- `tasks.json` — tasks customizadas (lint, contagem de palavras, setup);
- `extensions.json` — extensões recomendadas, sugeridas automaticamente ao abrir o projeto.

Não é aconselhado mexer nesses arquivos sem necessidade. Eles foram ajustados para que o template funcione igual em qualquer máquina da equipe.

### 3.9. `tools/`

Pasta com scripts e arquivos de configuração das ferramentas auxiliares (lint LaTeX e contagem oficial de palavras SAE).

A documentação detalhada está em `tools/README.md`. Veja resumo na [Seção 8](#8-ferramentas-auxiliares-tools).

### 3.10. `build/`

Pasta usada para arquivos gerados automaticamente durante a compilação.

Não é necessário mexer nela.

Essa pasta **não deve ser enviada para o Git** (já está no `.gitignore`).

---

## 4. O que normalmente deve ser editado

### 4.1. Alterar informações básicas do relatório

Edite no arquivo:

```text
main.tex
```

Normalmente, você altera:

- competição;
- data;
- número da equipe;
- e-mail;
- orientador;
- lista de alunos;
- caminhos das logos, se necessário.

### 4.2. Adicionar um novo capítulo

Crie um novo arquivo dentro da pasta `capitulos/`.

Exemplo:

```text
capitulos/cargas.tex
```

Dentro do arquivo, escreva:

```latex
\chapter{Cargas}

Texto do capítulo de cargas.
```

Depois, abra:

```text
sec/documento.tex
```

E adicione o capítulo na ordem desejada:

```latex
\include{capitulos/cargas.tex}
```

Exemplo:

```latex
\include{capitulos/introducao.tex}
\include{capitulos/requisitos.tex}
\include{capitulos/cargas.tex}
\include{capitulos/aerodinamica.tex}
\include{capitulos/conclusao.tex}
```

### 4.3. Adicionar uma imagem

Coloque a imagem na pasta:

```text
imagens/
```

Exemplo:

```text
imagens/grafico_desempenho.png
```

Depois, no capítulo onde ela será usada, escreva:

```latex
\begin{figure}[H]
    \centering
    \includegraphics[width=0.75\textwidth]{imagens/grafico_desempenho.png}
    \caption{Gráfico de desempenho da aeronave.}
    \label{fig:grafico-desempenho}
\end{figure}
```

Para citar a figura no texto:

```latex
O resultado é mostrado na \autoref{fig:grafico-desempenho}.
```

### 4.4. Adicionar uma referência

Abra o arquivo:

```text
referencias.bib
```

Adicione a referência em formato BibTeX:

```bibtex
@book{raymer2018,
  author    = {Daniel P. Raymer},
  title     = {Aircraft Design: A Conceptual Approach},
  year      = {2018},
  publisher = {AIAA}
}
```

Depois cite no texto:

```latex
A metodologia de projeto conceitual é apresentada em \cite{raymer2018}.
```

Ou:

```latex
Segundo \cite{raymer2018}, ...
```

### 4.5. Fluxo básico para editar o relatório

1. Atualizar seu projeto com `git pull`;
2. Alterar as informações da equipe em `main.tex`, se necessário;
3. Colocar imagens novas em `imagens/`;
4. Colocar logos novas em `logos/`, se necessário;
5. Escrever os capítulos dentro de `capitulos/`;
6. Organizar a ordem dos capítulos em `sec/documento.tex`;
7. Atualizar referências em `referencias.bib`;
8. Compilar o PDF;
9. Conferir se o PDF está correto;
10. Conferir o lint (já roda automaticamente ao salvar);
11. Fazer commit e push das alterações no repositório real do relatório.

---

## 5. Como compilar o relatório

### 5.1. Pelo VS Code

1. Abra a pasta do projeto no VS Code;
2. Abra o arquivo `main.tex`;
3. Use a extensão **LaTeX Workshop**;
4. Compile o projeto (ou apenas salve com `Ctrl + S` — a compilação acontece automaticamente);
5. O PDF será gerado na raiz do projeto.

### 5.2. Como funciona internamente

O template usa `latexmk` com a recipe configurada em `.vscode/settings.json`:

- PDF final fica na raiz do projeto (`main.pdf`);
- Arquivos auxiliares (`.aux`, `.log`, `.bbl`, etc.) ficam dentro de `build/`;
- Compilação roda com `-shell-escape` (necessário para alguns pacotes);
- SyncTeX habilitado (`Ctrl + clique` no PDF leva ao código).

Não é necessário mudar essas configurações.

---

## 6. LaTeX Workshop no VS Code

### 6.1. Compilar pelo LaTeX Workshop

Abra a paleta de comandos:

```text
Ctrl + Shift + P
```

Procure por:

```text
LaTeX Workshop: Build LaTeX project
```

Também é possível compilar usando o botão da extensão LaTeX Workshop na barra lateral, ou simplesmente salvando o arquivo (`Ctrl + S`).

### 6.2. Abrir o PDF dentro do VS Code

Depois de compilar, abra a paleta de comandos:

```text
Ctrl + Shift + P
```

Procure por:

```text
LaTeX Workshop: View LaTeX PDF
```

### 6.3. Trabalhar com código e PDF lado a lado

1. Abra o arquivo `.tex`;
2. Abra o PDF pelo LaTeX Workshop;
3. Arraste a aba do PDF para o lado direito da tela.

Organização recomendada:

```text
Esquerda: arquivos .tex
Direita:  PDF compilado
```

### 6.4. Ir do código para o PDF (SyncTeX)

Com o cursor em uma linha do arquivo `.tex`, use:

```text
Ctrl + Alt + J
```

Se o atalho não funcionar, abra a paleta de comandos e procure:

```text
LaTeX Workshop: SyncTeX from cursor
```

### 6.5. Ir do PDF para o código

No visualizador de PDF do LaTeX Workshop:

```text
Duplo clique no PDF
```

Isso leva diretamente ao ponto correspondente no código LaTeX.

### 6.6. Quando a sincronização não funcionar

A sincronização entre PDF e código pode falhar se:

- o projeto não foi compilado corretamente;
- o arquivo PDF está desatualizado;
- há erro de LaTeX;
- o arquivo `.synctex.gz` não foi gerado;
- o PDF foi aberto fora do visualizador do LaTeX Workshop.

Para corrigir:

1. Salve os arquivos;
2. Compile novamente;
3. Feche e abra o PDF pelo LaTeX Workshop;
4. Verifique se há erros de compilação.

---

## 7. Tasks do VS Code

O projeto tem quatro tasks configuradas em `.vscode/tasks.json`. Para executar manualmente:

```text
Ctrl + Shift + P > Tasks: Run Task
```

| Task | O que faz | Quando usar |
|------|-----------|-------------|
| **LaTeX Lint** | Roda o linter em todos os `.tex`. | Roda automaticamente ao abrir o projeto e ao salvar qualquer `.tex`. Raramente precisa rodar manualmente. |
| **LaTeX Lint — Watch** | Versão manual do lint. | Use quando quiser rodar o lint sem salvar. |
| **SAE Word Count: Setup** | Baixa o `PyAeroCounter.exe` e valida dependências (Tesseract, MiKTeX). | Execute **uma única vez** após clonar o repositório. |
| **SAE Word Count** | Conta palavras do `main.pdf` usando o padrão oficial SAE. | Antes de submeter o relatório. Demora vários minutos. |

O lint automático ao salvar depende da extensão **Trigger Task on Save**. Se ela não estiver instalada, o VS Code sugere a instalação ao abrir o projeto.

Detalhes completos sobre cada ferramenta estão em `tools/README.md`.

---

## 8. Ferramentas auxiliares (`tools/`)

A pasta `tools/` contém:

```text
tools/
├── README.md                   -> documentação detalhada
├── count_words.ps1             -> dispara o PyAeroCounter
├── setup_pyaerocounter.ps1     -> instala o PyAeroCounter
├── lint_tex.lua                -> linter LaTeX customizado
├── forbidden_words.txt         -> palavras a evitar (avisos do lint)
├── markers.txt                 -> marcadores de TODO/FIXME
└── PyAeroCounter.exe           -> baixado pelo setup (NÃO vai pro Git)
```

Resumo do que cada coisa faz:

- **Contagem de palavras (SAE Word Count)** — usa o **PyAeroCounter**, ferramenta oficial da SAE, para contar palavras do PDF compilado. O script `setup_pyaerocounter.ps1` baixa o executável; `count_words.ps1` roda a contagem.

- **Lint LaTeX** — verifica problemas comuns nos arquivos `.tex` (palavras informais, erros de digitação, marcadores TODO/FIXME esquecidos). Roda automaticamente ao salvar.

- **Palavras proibidas** — lista em `forbidden_words.txt`. Quando o lint encontra uma dessas palavras em um `.tex`, exibe um aviso.

- **Marcadores** — lista em `markers.txt`. Quando o lint encontra um marcador (ex.: `TODO`, `FIXME`), exibe um aviso para você não esquecer de resolver antes de entregar.

Para detalhes completos (como configurar, como funciona cada arquivo, troubleshooting), leia:

```text
tools/README.md
```

---

## 9. Git e GitHub

### 9.1. Para que serve o Git

O Git serve para controlar as versões do projeto.

Com ele é possível:

- salvar o histórico de alterações;
- saber quem alterou cada arquivo;
- voltar para versões anteriores;
- trabalhar em equipe sem sobrescrever tudo;
- enviar o projeto para o GitHub;
- criar branches para testar alterações sem afetar a versão principal.

Em um relatório colaborativo, o Git é importante porque várias pessoas podem trabalhar em capítulos, figuras, referências e arquivos diferentes sem perder o controle do projeto.

### 9.2. O que é GitHub

O GitHub é uma plataforma online onde o repositório Git fica hospedado.

```text
Git    = controla versões no computador
GitHub = armazena o projeto online
```

O GitHub permite que a equipe:

- compartilhe o projeto;
- trabalhe de computadores diferentes;
- revise alterações;
- mantenha uma cópia segura online;
- organize branches, issues e versões do relatório.

### 9.3. Configuração inicial do Git

Esta configuração só precisa ser feita **uma vez em cada computador**.

#### Onde digitar os comandos

Use o terminal integrado do VS Code:

```text
Terminal > New Terminal
```

Ou o atalho:

```text
Ctrl + `
```

#### Configurar nome e e-mail

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seuemail@exemplo.com"
```

Exemplo:

```bash
git config --global user.name "Henry Matheus Hagemann"
git config --global user.email "henry@email.com"
```

Use preferencialmente o mesmo e-mail associado à sua conta do GitHub.

#### Conferir se a configuração funcionou

```bash
git config --global --list
```

Deve aparecer:

```text
user.name=Seu Nome
user.email=seuemail@exemplo.com
```

Essa configuração vale para todos os repositórios Git desse computador. Não é necessário rodar de novo a cada projeto.

---

## 10. Como criar um novo projeto a partir do template

### 10.1. Não trabalhe diretamente no template

Antes de fazer alterações importantes, confira se você está no repositório correto:

```bash
git remote -v
```

Se aparecer `Template-Uira`, **cuidado**: você está conectado ao template, não ao relatório real.

Para um relatório real, deveria aparecer algo como:

```text
Relatorio-Uira-2026
```

### 10.2. Opção recomendada: criar via "Use this template" no GitHub

1. Acesse o repositório do template no GitHub:

   ```text
   https://github.com/HenryHagemann/Template-Uira
   ```

2. Clique em **Use this template > Create a new repository**;

3. Defina um nome para o novo projeto. Exemplos:

   ```text
   Relatorio-Uira-2026
   Relatorio-Tecnico-2026
   Relatorio-SAE-2026
   ```

4. Crie o novo repositório no GitHub.

5. No seu computador, clone o **novo repositório** (não o template) seguindo a [Seção 10.4](#104-clonar-o-repositório-no-computador).

### 10.3. Opção alternativa: clonar o template e trocar o remote

Use esta opção se o botão **Use this template** não estiver disponível.

```bash
git clone https://github.com/HenryHagemann/Template-Uira.git
cd Template-Uira
git remote remove origin
git remote add origin https://github.com/USUARIO/Relatorio-Uira-2026.git
git branch -M main
git push -u origin main
```

Confira que o remote está correto:

```bash
git remote -v
```

Deve aparecer `Relatorio-Uira-2026`, não `Template-Uira`.

Renomeie a pasta local para evitar confusão:

```text
Template-Uira -> Relatorio-Uira-2026
```

### 10.4. Clonar o repositório no computador

Esse fluxo serve tanto para criar um novo projeto quanto para novos integrantes que vão entrar em um projeto existente.

**1. Crie uma pasta geral para guardar os projetos da equipe.**

Exemplo no Windows:

```text
D:\Uira
```

**2. Abra essa pasta no VS Code:**

```text
File > Open Folder > D:\Uira
```

**3. Abra o terminal integrado:**

```text
Terminal > New Terminal
```

O terminal deve abrir em `D:\Uira>`.

**4. Clone o repositório real do relatório:**

```bash
git clone https://github.com/USUARIO/Relatorio-Uira-2026.git
```

O Git criará a pasta:

```text
D:\Uira\Relatorio-Uira-2026
```

**5. (Opcional) Clonar com outro nome de pasta:**

```bash
git clone https://github.com/USUARIO/Relatorio-Uira-2026.git Relatorio_Sistemas_Eletricos
```

Atenção: isso só muda o **nome da pasta local**. O repositório remoto continua sendo o mesmo.

**6. Abra a pasta clonada como projeto principal no VS Code:**

```text
File > Open Folder > D:\Uira\Relatorio-Uira-2026
```

**7. Após abrir, rode o setup do PyAeroCounter uma vez** (apenas se você for usar a contagem de palavras):

```text
Ctrl + Shift + P > Tasks: Run Task > SAE Word Count: Setup
```

A partir daqui, todo o trabalho deve ser feito **dentro da pasta clonada**.

A pasta `D:\Uira` serve só para organizar os projetos. **Não edite arquivos diretamente nela.**

---

## 11. Fluxo de trabalho com Git

### 11.1. Comandos básicos

#### Ver o estado do projeto

```bash
git status
```

Use com frequência, principalmente antes de fazer commit.

#### Baixar alterações do GitHub

Antes de começar a mexer:

```bash
git pull
```

#### Adicionar alterações para o commit

Adicionar **todos** os arquivos alterados:

```bash
git add .
```

Adicionar **apenas um arquivo específico**:

```bash
git add capitulos/aerodinamica.tex
```

Outros exemplos:

```bash
git add referencias.bib
git add imagens/grafico_desempenho.png
```

`git add` não envia nada para o GitHub. Ele apenas prepara as alterações para o commit.

Fluxo completo:

```text
git add    -> escolhe o que entra no commit
git commit -> salva uma versão no histórico local
git push   -> envia os commits para o GitHub
```

#### Criar um commit

```bash
git commit -m "Mensagem do commit"
```

Use mensagens claras.

Ruim:

```bash
git commit -m "alteracoes"
git commit -m "coisas"
```

Bom:

```bash
git commit -m "Atualiza lista de alunos"
git commit -m "Adiciona imagens da análise estrutural"
git commit -m "Corrige referências bibliográficas"
```

#### Enviar para o GitHub

```bash
git push
```

Se o push falhar porque existem alterações novas no GitHub:

```bash
git pull
git push
```

### 11.2. Fluxo recomendado

Antes de começar:

```bash
git pull
git status
```

Depois de editar (tudo):

```bash
git status
git add .
git commit -m "Descreve a alteração feita"
git push
```

Depois de editar (apenas um arquivo):

```bash
git status
git add capitulos/desempenho.tex
git commit -m "Atualiza capítulo de desempenho"
git push
```

Regra simples:

```text
Sempre dê git pull antes de começar.
Sempre rode git status antes de adicionar arquivos.
Use git add . apenas quando tiver certeza de que quer incluir tudo.
Use git add arquivo quando quiser controlar melhor o commit.
Sempre dê git push quando terminar.
Nunca deixe alterações importantes apenas no seu computador.
```

### 11.3. Arquivos que não devem ir para o Git

O `.gitignore` impede que arquivos gerados sejam enviados ao GitHub.

Arquivos que **não devem** ser enviados:

```text
build/
main.pdf
main.synctex.gz
*.aux
*.log
*.toc
*.out
*.bbl
*.blg
*.fls
*.fdb_latexmk
tools/PyAeroCounter.exe
tools/pyaerocounter/
```

Arquivos que **devem** ser enviados:

```text
main.tex
uira_template.sty
referencias.bib
capitulos/
sec/
imagens/
logos/
tools/*.ps1
tools/*.lua
tools/*.txt
tools/README.md
README.md
.gitignore
.vscode/
```

### 11.4. Se o Git tentar enviar arquivos gerados

Se arquivos como `main.pdf` ou `build/` foram adicionados por engano:

```bash
git rm --cached main.pdf
git rm -r --cached build/
git commit -m "Remove arquivos gerados do controle do Git"
git push
```

### 11.5. Duas pessoas editando ao mesmo tempo

Se duas pessoas editarem arquivos diferentes, normalmente o Git junta sem conflito.

Exemplo:

```text
Pessoa 1 -> capitulos/aerodinamica.tex
Pessoa 2 -> capitulos/desempenho.tex
```

Cada um faz seu commit normalmente. Se o push da segunda pessoa for recusado:

```bash
git pull
git push
```

#### Quando pode dar conflito

- Duas pessoas editando o **mesmo arquivo**, principalmente nas mesmas linhas;
- Duas pessoas editando ao mesmo tempo um arquivo central.

Arquivos com maior chance de conflito:

```text
main.tex
sec/documento.tex
referencias.bib
uira_template.sty
```

#### Regra prática

```text
Arquivos diferentes:              normalmente sem conflito.
Mesmo arquivo, partes diferentes: pode funcionar, exige cuidado.
Mesmo arquivo, mesmas linhas:     grande chance de conflito.
Arquivos centrais:                maior chance de conflito.
```

Para evitar problemas:

- `git pull` antes de começar;
- combine quem edita cada arquivo;
- evite duas pessoas mexendo ao mesmo tempo em `main.tex`, `sec/documento.tex`, `referencias.bib` e `uira_template.sty`;
- faça commits pequenos;
- `git status` antes de adicionar;
- `git push` ao terminar uma alteração importante.

---

## 12. Branches

### 12.1. Para que servem

Branches servem para trabalhar em alterações sem mexer diretamente na versão principal.

A branch principal normalmente se chama `main`.

Use branches quando for fazer alterações maiores:

- reorganizar capítulos;
- mudar muitas seções;
- alterar o template;
- testar uma nova estrutura;
- revisar um capítulo inteiro;
- fazer mudanças que podem quebrar a compilação.

### 12.2. Comandos

Criar uma nova branch:

```bash
git switch -c nome-da-branch
```

Exemplo:

```bash
git switch -c revisao-aerodinamica
```

Ver em qual branch você está:

```bash
git branch
```

Voltar para a `main`:

```bash
git switch main
```

Enviar branch nova para o GitHub (primeira vez):

```bash
git push -u origin nome-da-branch
```

Nas próximas vezes:

```bash
git push
```

### 12.3. Juntar a branch na `main`

```bash
git switch main
git pull
git merge revisao-aerodinamica
git push
```

Apagar branch local:

```bash
git branch -d revisao-aerodinamica
```

Apagar branch no GitHub:

```bash
git push origin --delete revisao-aerodinamica
```

### 12.4. Regra prática

- **Alterações pequenas** (correções, troca de imagens, atualização de nome): pode trabalhar direto na `main`, se a equipe permitir.

- **Alterações grandes** (reescrita de capítulo, mudança no template, reorganização): use branch.

---

## 13. Conflitos

### 13.1. O que é um conflito

Conflito acontece quando duas pessoas alteram a mesma parte do mesmo arquivo.

O Git mostra algo assim:

```text
<<<<<<< HEAD
Texto da sua versão.
=======
Texto da versão de outra pessoa.
>>>>>>> nome-da-branch
```

### 13.2. Como resolver

1. Abra o arquivo com conflito;
2. Leia as duas versões;
3. Escolha qual texto deve ficar;
4. Apague as marcações do Git (`<<<<<<<`, `=======`, `>>>>>>>`);
5. Salve o arquivo;
6. Adicione o arquivo resolvido;
7. Faça um commit.

```bash
git add capitulos/aerodinamica.tex
git commit -m "Resolve conflito no capítulo de aerodinâmica"
git push
```

### 13.3. Como evitar

- `git pull` antes de começar;
- evite duas pessoas no mesmo trecho;
- divida o relatório por capítulos;
- avise a equipe em qual arquivo você está;
- commits pequenos e frequentes;
- `git status` antes de fazer commit;
- `git add arquivo` para controle fino;
- use Live Share quando várias pessoas forem editar juntas.

Exemplo de divisão:

```text
Pessoa 1 -> capitulos/aerodinamica.tex
Pessoa 2 -> capitulos/desempenho.tex
Pessoa 3 -> capitulos/estabilidade.tex
Pessoa 4 -> referencias.bib
```

---

## 14. Live Share

### 14.1. Para que serve

O Live Share permite que várias pessoas editem o mesmo projeto ao mesmo tempo no VS Code.

Útil para:

- revisar texto em grupo;
- resolver erro de compilação;
- editar um capítulo em dupla;
- explicar uma parte do relatório;
- acompanhar alterações em tempo real;
- simular experiência parecida com Overleaf.

```text
Live Share NÃO substitui Git.
```

O histórico oficial continua sendo controlado pelo Git. Alguém precisa fazer commit e push no final.

### 14.2. Iniciar uma sessão (host)

1. Abra a pasta do projeto no VS Code;
2. Clique no ícone do **Live Share** na barra lateral;
3. Clique em **Start Collaboration Session**;
4. Copie o link gerado;
5. Envie o link para os outros integrantes.

### 14.3. Compartilhar o PDF compilado com o convidado

O LaTeX Workshop roda um **servidor local** na máquina do host para exibir o PDF. Para o convidado conseguir ver, esse servidor precisa ser **exposto via Live Share**.

#### Passo 1 — Host: liberar (allow) a porta

Ao iniciar a sessão, o VS Code do host **automaticamente** pergunta se quer liberar a porta. A notificação aparece assim:

```text
LaTeX Workshop would like to share port 60584.
```

Clique em **Allow**.

> A porta varia a cada sessão (60584, 52341, etc.). Não precisa decorar — só clicar Allow.

#### Passo 2 — Convidado: abrir o PDF pela primeira vez

Esse passo tem uma pegadinha: na **primeira vez** que o convidado abre o PDF na sessão, pode ser que ele precise estar com o **`main.tex` ativo na aba**.

**Convidado, primeira vez:**

1. Na árvore de arquivos, clique em `main.tex` (deixe ele como aba ativa);
2. Pressione `Ctrl + Alt + V`;
3. O PDF do host aparece numa aba ao lado.

**Depois disso (nas vezes seguintes):**

- Pode estar em qualquer arquivo (`.tex`, `.bib`, etc.);
- `Ctrl + Alt + V` funciona normal;
- Ou clica no ícone **View LaTeX PDF** da barra superior.

> Se pular o passo do `main.tex` na primeira vez, o PDF pode não abrir ou aparecer em branco. Feche a aba do PDF, volte pro `main.tex` e tente de novo.
>
> **O convidado não compila nada.** A compilação acontece sempre na máquina do host. O convidado apenas visualiza o PDF gerado.
>
> **Não precisa rodar `Acquire HOST's PDF Viewer port`.** Em versões recentes do LaTeX Workshop, basta o host ter liberado a porta (passo 1) para o `Ctrl + Alt + V` funcionar.

#### Se o popup do Allow não apareceu

Acontece. Pode ser que o host tenha clicado fora sem querer, ou que o LaTeX Workshop ainda não tinha subido o servidor quando a sessão começou.

**Host — compartilhar manualmente:**

1. `Ctrl + Shift + P`;
2. Digite `LaTeX Workshop: Share`;
3. Selecione a opção que aparece (algo como *"Share (on host) / Acquire (on guest) Live Share"*);
4. O popup do **Allow** aparece → clique em **Allow**.

Depois disso, o convidado segue o procedimento normal (`main.tex` ativo + `Ctrl + Alt + V`).

#### Conferindo se a porta está compartilhada

**Host:**

1. Abra o painel do **Live Share** na barra lateral esquerda;
2. Procure a seção **Shared Servers**;
3. Deve aparecer algo como:

```text
LaTeX Workshop PDF Viewer  ->  localhost:60584
```

Se não aparecer, repita o passo anterior (`LaTeX Workshop: Share` na paleta de comandos).

> Com a porta listada em Shared Servers, todos os convidados conseguem abrir o PDF.

#### PDF preto, em branco ou não carrega

Mesmo com tudo certo, na primeira tentativa o PDF às vezes vem preto. É comportamento conhecido da combinação Live Share + LaTeX Workshop.

**Ordem de tentativas (convidado):**

1. Feche a aba do PDF e abra de novo (`Ctrl + Alt + V` com `main.tex` ativo);
2. Tente 2 ou 3 vezes seguidas — geralmente destrava;
3. Se persistir: peça ao host pra rodar `LaTeX Workshop: Share` de novo.

**Diagnóstico avançado (se nada resolver):**

No convidado:

```text
Ctrl + Shift + P > Developer: Open Webview Developer Tools
```

Erros comuns no console:

- `Failed to fetch` -> porta não compartilhada (host roda `LaTeX Workshop: Share`);
- `Refused to connect` -> firewall bloqueando.


### 14.4. Fluxo recomendado

Antes da sessão (host):

```bash
git pull
git status
```

Durante a sessão, defina papéis:

```text
Pessoa 1 -> controla Git
Pessoa 2 -> controla compilação (host)
Pessoa 3 -> revisa texto
Pessoa 4 -> edita imagens/tabelas
```

Depois da sessão:

```bash
git status
git add .
git commit -m "Atualiza relatório em sessão Live Share"
git push
```

### 14.5. Cuidados

Evite que várias pessoas mexam ao mesmo tempo em:

```text
main.tex
uira_template.sty
sec/documento.tex
referencias.bib
```

### 14.6. Comparação com Overleaf

```text
Overleaf:
  edição online + compilação online + colaboração integrada

VS Code + Git + Live Share:
  edição local + compilação local + GitHub + colaboração em tempo real
```

Para chegar perto da experiência do Overleaf:

- VS Code + LaTeX Workshop;
- PDF lado a lado;
- SyncTeX;
- Live Share;
- GitHub.

---

## 15. Checklist antes de fazer push

- [ ] Você está no repositório correto, **não no template** (`git remote -v`);
- [ ] Você rodou `git pull` antes de começar;
- [ ] O relatório compila sem erro;
- [ ] O PDF abre corretamente;
- [ ] As imagens aparecem corretamente;
- [ ] As referências aparecem corretamente;
- [ ] As citações não estão como `??`;
- [ ] Os capítulos estão na ordem certa em `sec/documento.tex`;
- [ ] O lint não está mostrando erros graves (painel **Problems** do VS Code);
- [ ] Não há marcadores `TODO`/`FIXME` esquecidos em texto que vai pro relatório final;
- [ ] O `git status` não mostra arquivos gerados indesejados;
- [ ] Você adicionou apenas os arquivos que queria no commit;
- [ ] A mensagem do commit está clara.

---

## 16. Fluxo mínimo para novos integrantes

### 16.1. Primeira vez

Siga a [Seção 10.4](#104-clonar-o-repositório-no-computador) para clonar o repositório real do relatório.

Depois de clonar e abrir a pasta no VS Code:

1. Aceite a instalação das extensões recomendadas (popup automático);
2. Configure seu Git ([Seção 9.3](#93-configuração-inicial-do-git));
3. Rode o setup do PyAeroCounter (apenas se for usar contagem de palavras):

   ```text
   Ctrl + Shift + P > Tasks: Run Task > SAE Word Count: Setup
   ```

### 16.2. Antes de editar

```bash
git pull
git status
```

### 16.3. Depois de editar

```bash
git status
git add .
git commit -m "Descreve a alteração feita"
git push
```

Se o push falhar:

```bash
git pull
git push
```

Se houver conflito, resolva no arquivo indicado, salve, commit e tente novamente.

### 16.4. Regra mais importante

```text
Não trabalhe diretamente no repositório do template.
Clone o repositório real do relatório.
Trabalhe dentro da pasta clonada, não dentro da pasta geral.
Sempre dê git pull antes de editar.
Sempre rode git status antes de fazer commit.
Use git add . apenas quando quiser adicionar tudo.
Use git add arquivo quando quiser adicionar somente alterações específicas.
Sempre dê git push depois de terminar.
Use Live Share para colaboração em tempo real.
Use Git para registrar oficialmente as alterações.
```
