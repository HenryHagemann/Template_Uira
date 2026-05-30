#!/usr/bin/env texlua
-- Lint de arquivos .tex: palavras proibidas + marcadores.
-- Varre sec/ e capitulos/ recursivamente.
-- Saída no formato file:line:col: severity: message (compatível com file-line-error).
-- Caminhos sempre relativos à raiz do projeto, para o problemMatcher do VS Code resolver corretamente.
-- Sempre encerra com exit 0 (informacional).

local lfs_ok, lfs = pcall(require, "lfs")
if not lfs_ok then
    io.stderr:write("lint-tex: LuaFileSystem indisponível. Pulei o lint.\n")
    os.exit(0)
end

-- Resolve a raiz do projeto: tools/ está em <root>/tools/
local script_path = arg[0]:gsub("\\", "/")
local script_dir  = script_path:match("(.*/)") or "./"
local root        = script_dir:gsub("/$", "")          -- remove barra final
root              = root:match("(.*)/[^/]+$") or "."   -- sobe um nível (sai de /tools)

local SCAN_DIRS    = { "sec", "capitulos" }
local WORDS_FILE   = script_dir .. "forbidden_words.txt"
local MARKERS_FILE = script_dir .. "markers.txt"

-- ----------------------------------------------------------------------------
-- Converte um caminho absoluto em relativo à raiz do projeto.
-- Se já for relativo, devolve como está.
local function to_relative(path, base)
    local norm_path = path:gsub("\\", "/")
    local norm_base = base:gsub("\\", "/"):gsub("/$", "")

    if norm_base == "" or norm_base == "." then
        -- Sem base útil: devolve normalizado.
        return norm_path
    end

    -- Comparação case-insensitive (Windows não distingue maiúsculas no caminho).
    local lower_path = norm_path:lower()
    local lower_base = norm_base:lower()

    if lower_path:sub(1, #lower_base) == lower_base then
        local rel = norm_path:sub(#norm_base + 1)
        rel = rel:gsub("^/+", "")  -- remove barras iniciais
        return rel
    end
    return norm_path
end

local function load_list(path)
    local list = {}
    local f = io.open(path, "r")
    if not f then return list end
    for line in f:lines() do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed ~= "" and not trimmed:match("^#") then
            table.insert(list, trimmed)
        end
    end
    f:close()
    return list
end

local function escape_pattern(s)
    return (s:gsub("([^%w])", "%%%1"))
end

-- Lua patterns não têm \b. Usamos checagem manual de fronteira.
local function is_word_char(c)
    if not c or c == "" then return false end
    -- ASCII letras/dígitos/underscore
    if c:match("[%w_]") then return true end
    -- bytes >= 128 (multi-byte UTF-8 de acentos): trate como letra
    if c:byte() >= 128 then return true end
    return false
end

local function find_all(line, term)
    local results = {}
    local lower_line = line:lower()
    local lower_term = term:lower()
    local pat = escape_pattern(lower_term)
    local init = 1
    while true do
        local s, e = lower_line:find(pat, init, false)
        if not s then break end
        local before = s > 1 and lower_line:sub(s - 1, s - 1) or ""
        local after  = e < #lower_line and lower_line:sub(e + 1, e + 1) or ""
        if not is_word_char(before) and not is_word_char(after) then
            table.insert(results, { col = s, match = line:sub(s, e) })
        end
        init = e + 1
    end
    return results
end

-- ----------------------------------------------------------------------------
local function scan_file(path, forbidden, markers, issues)
    local f = io.open(path, "r")
    if not f then return end
    local lineno = 0
    for line in f:lines() do
        lineno = lineno + 1
        local is_comment = line:match("^%s*%%") ~= nil

        if not is_comment then
            for _, term in ipairs(forbidden) do
                for _, hit in ipairs(find_all(line, term)) do
                    table.insert(issues, {
                        file = path, line = lineno, col = hit.col,
                        sev = "warning",
                        msg = "palavra proibida: '" .. hit.match .. "'",
                    })
                end
            end
        end

        -- marcadores: pegam em comentário também
        for _, term in ipairs(markers) do
            for _, hit in ipairs(find_all(line, term)) do
                table.insert(issues, {
                    file = path, line = lineno, col = hit.col,
                    sev = "warning",
                    msg = "marcador: '" .. hit.match .. "'",
                })
            end
        end
    end
    f:close()
end

local function walk(dir, issues, forbidden, markers)
    local attr = lfs.attributes(dir)
    if not attr or attr.mode ~= "directory" then return end
    for entry in lfs.dir(dir) do
        if entry ~= "." and entry ~= ".." then
            local full = dir .. "/" .. entry
            local a = lfs.attributes(full)
            if a and a.mode == "directory" then
                walk(full, issues, forbidden, markers)
            elseif a and a.mode == "file" and entry:match("%.tex$") then
                scan_file(full, forbidden, markers, issues)
            end
        end
    end
end

-- ----------------------------------------------------------------------------
local forbidden = load_list(WORDS_FILE)
local markers   = load_list(MARKERS_FILE)

local issues = {}
for _, d in ipairs(SCAN_DIRS) do
    walk(root .. "/" .. d, issues, forbidden, markers)
end

table.sort(issues, function(a, b)
    if a.file ~= b.file then return a.file < b.file end
    if a.line ~= b.line then return a.line < b.line end
    return a.col < b.col
end)

for _, it in ipairs(issues) do
    -- Formato file-line-error: o LaTeX Workshop reconhece como warning do build.
    -- Caminho sempre relativo à raiz, para o problemMatcher resolver corretamente.
    local rel_file = to_relative(it.file, root)
    print(string.format("%s:%d:%d: %s: %s",
        rel_file, it.line, it.col, it.sev, it.msg))
end

if #issues == 0 then
    print("lint-tex: nenhum problema encontrado.")
else
    io.stderr:write(string.format("lint-tex: %d ocorrencia(s).\n", #issues))
end

os.exit(0)
