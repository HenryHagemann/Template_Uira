# Relatório Técnico — Uirá Aerodesign 🛩️

Template LaTeX para os relatórios do time **Uirá Aerodesign**.
Este README mostra o essencial: **instalar, clonar, configurar, compilar, contar palavras e editar as listas de verificação**.

> ⚠️ **Não edite este repositório diretamente.**
> Crie o seu a partir dele em **Use this template > Create a new repository**.

---

## 1. Instale (uma única vez)

Baixe e instale:

- [Git](https://git-scm.com/downloads)
- [VS Code](https://code.visualstudio.com/Download)

> O resto das ferramentas (LaTeX, scripts de contagem, etc.) é instalado pelo **setup** no passo 4 — não precisa instalar manualmente.

---

## 2. Crie seu projeto a partir do template

No GitHub, na página deste repositório, clique em:

> **Use this template > Create a new repository**

Ao criar, configure assim:

1. **Nome**: dê um nome ao projeto (ex.: `Relatorio-Uira-2026`);
2. **Visibilidade: marque como `Private` (Privado).** ⚠️ **Isso é obrigatório.**

### ⚠️ Por que o repositório TEM que ser privado

O relatório é **segredo de equipe**. Ele contém o **projeto técnico da aeronave**: cálculos, decisões de engenharia, estratégias de competição e soluções desenvolvidas pelo time.

- 🔒 Se o repositório for **público**, **qualquer pessoa na internet** pode ver, copiar e usar nosso trabalho — incluindo **equipes concorrentes**.
- 📜 Além disso, divulgar esse conteúdo pode violar as regras da equipe.

> **Regra de ouro:** o repositório do relatório **nunca** pode ser público. Em caso de dúvida, deixe privado.

### Compartilhe com os membros do relatório

Como o projeto é privado, só você o enxerga até liberar acesso. Adicione **cada membro que vai trabalhar no relatório**:

1. No seu repositório, vá em **Settings > Collaborators** (Configurações > Colaboradores);
2. Clique em **Add people**;
3. Digite o **usuário do GitHub** ou o **e-mail** de cada membro e confirme;
4. O membro recebe um convite e precisa **aceitar** para ter acesso.

> 💡 Adicione **somente** os integrantes que realmente vão mexer no relatório. Quanto menos gente com acesso, mais seguro.

---

## 3. Clone no seu PC

Abra o terminal e rode (troque pela URL do **seu** repositório):

```bash
git clone https://github.com/SEU_USUARIO/SEU_REPO.git
```

Depois, abra a pasta no VS Code: `File > Open Folder`.

---

## 4. Configure tudo — rode o setup ANTES de compilar (uma única vez)

> ⚠️ **Esse passo é obrigatório e vem antes de qualquer compilação.**
> Sem ele, o projeto **não compila**, porque as ferramentas ainda não estão instaladas.

1. Ao abrir o projeto, **aceite as extensões recomendadas** que o VS Code sugerir;
2. Rode a task de setup:

   > `Ctrl + Shift + P` → **Tasks: Run Task** → **Setup: Install Dependencies**

3. Aguarde a instalação terminar e **reinicie o PC**.

### O que o setup instala

A task baixa e configura automaticamente tudo que o projeto precisa para funcionar:

| Ferramenta | Para que serve |
|------------|----------------|
| **MiKTeX (LaTeX)** | Compila o `.tex` e gera o PDF do relatório. |
| **Strawberry Perl** | Necessário para o `latexmk`, que automatiza a compilação. |
| **Inkscape** | Permite usar imagens vetoriais (`.svg`) no relatório. |
| **Tesseract (OCR)** | Lê texto dentro de imagens para a contagem de palavras. |
| **PyAeroCounter** | Faz a contagem de palavras no padrão oficial SAE. |
| **Extensões do VS Code** | LaTeX Workshop, contagem ao salvar, Live Share, etc. |

> 💡 É normal demorar alguns minutos e abrir janelas de instalação. Deixe concluir e **só depois reinicie o PC**.

---

## 5. Compile o relatório

> Só funciona **depois** de concluir o passo 4 e reiniciar o PC.

1. Abra o `main.tex`;
2. Salve com `Ctrl + S`.

O PDF é gerado automaticamente ao lado. 🎉

---

## 6. Tasks importantes

Acesse todas em:

> `Ctrl + Shift + P` → **Tasks: Run Task**

| Task | O que faz |
|------|-----------|
| **Setup: Install Dependencies** | Instala todas as dependências do projeto (rode só na primeira vez, antes de compilar). |
| **SAE Word Count** | Conta as palavras seguindo o padrão SAE. Resultado em `wordcount/logfile.txt`. |

> 💡 Use a **SAE Word Count** sempre que precisar validar o limite de palavras do relatório.

---

## 7. Editar as listas de verificação (`check_palavras/`)

O projeto verifica automaticamente **palavras a evitar** e **marcadores** (pendências deixadas no texto).
Essas listas ficam na pasta `check_palavras/`.

### 7.1. Palavras proibidas / a evitar

- Abra o arquivo de **palavras proibidas** em `check_palavras/`;
- Adicione **uma palavra por linha**;
- Salve. Na próxima verificação, essas palavras serão sinalizadas.

```text
exemplo
muito
basicamente
```

### 7.2. Marcadores (pendências)

Marcadores são trechos que **não podem ficar no relatório final** (ex.: `TODO`, `REVISAR`, `XXX`).

- Abra o arquivo de **marcadores** em `check_palavras/`;
- Adicione **um marcador por linha**;
- Salve.

```text
TODO
REVISAR
FIXME
CONFIRMAR
```

> 💡 Use marcadores no texto para lembrar de pendências. A verificação avisa se algum ficou para trás antes da entrega.

---

## 8. Enviar suas mudanças para o GitHub

```bash
git pull
git add .
git commit -m "Descreva suas mudanças"
git push
```

> Faça `git pull` **antes** de começar a editar e `git push` **sempre** que terminar.

---

## 📚 Material complementar (aulas)

Para se aprofundar, consulte as aulas:

- **Setup e estrutura de pastas**
- **Git do zero**
- **Live Share (edição colaborativa)**
- **LaTeXmk e compilação**

---

Dúvidas? Fale com o pessoal do time. Bom relatório! 🛩️
