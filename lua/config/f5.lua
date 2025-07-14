-- lua/config/f5.lua
local api = vim.api
local uv = vim.loop

-- 1. 向上查找 sdkconfig，返回 ESP-IDF 项目根目录（找到即返回，找不到返回 nil）
local function find_sdkconfig_root()
    local dir = vim.fn.expand("%:p:h")
    while dir and dir ~= "" and dir ~= "." do
        if uv.fs_stat(dir .. "/sdkconfig") then
            return dir
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            break
        end
        dir = parent
    end
    return nil
end

-- 2. 找到用户自己用 :terminal 打开的第一个内置终端 buffer
local function find_term_buf()
    for _, buf in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_valid(buf) and api.nvim_buf_get_option(buf, "buftype") == "terminal" then
            return buf
        end
    end
    return nil
end

-- 3. 往 terminal buffer 发送命令并自动回车
local function send_to_term(cmd)
    local buf = find_term_buf()
    if not buf then
        return vim.notify("⚠️ 请先用 :terminal 打开一个终端", vim.log.levels.WARN)
    end
    local chan = vim.b[buf].terminal_job_id
    if not chan then
        return vim.notify("⚠️ 终端尚未准备就绪", vim.log.levels.ERROR)
    end
    vim.fn.chansend(chan, cmd .. "\r")
end

-- 4. 简易 YAML 解析（支持下划线 key）
--    读取 .idfconfig.yaml，格式为 key: value，忽略空行 & 注释
local function parse_idfconfig(path)
    local conf = {}
    for _, line in ipairs(vim.fn.readfile(path)) do
        local s = line:match("^%s*(.-)%s*$")
        if s ~= "" and not s:match("^#") then
            local k, v = s:match("^([%w_]+)%s*:%s*(.+)$")
            if k and v then
                conf[k] = v:match("^%s*(.-)%s*$")
            end
        end
    end
    return conf
end

local function run_love_project()
    local dir = vim.fn.expand("%:p:h") -- 当前文件所在目录
    while dir ~= "" and dir ~= "." do
        if
            vim.loop.fs_stat(dir .. "/main.lua") -- 同时存在 main.lua …
            and vim.loop.fs_stat(dir .. "/conf.lua")
        then -- …与 conf.lua
            send_to_term("love " .. vim.fn.shellescape(dir))
            return true
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            break
        end
        dir = parent
    end
    return false
end

vim.keymap.set("n", "<F5>", function()
    local ft = vim.bo.filetype

    -- Markdown：浏览器预览
    if ft == "markdown" then
        return vim.cmd("MarkdownPreview")
    end

    -- Python：python <file>
    if ft == "python" then
        local file = vim.fn.expand("%:p")
        return send_to_term("python " .. vim.fn.shellescape(file))
    end

    -- LÖVE：一旦找到 main.lua+conf.lua 就 love <root>
    if run_love_project() then
        return
    end

    -- ESP-IDF：sdkconfig → idf.py build
    local root = find_sdkconfig_root()
    if root then
        return send_to_term("cd " .. vim.fn.shellescape(root) .. " && idf.py build")
    end

    -- 其它文件类型
    vim.notify("F5 只在 Markdown / Python / LÖVE / ESP-IDF 项目中有效", vim.log.levels.INFO)
end, { desc = "F5 → Build/Run" })

-- 6. 全局绑定 <F6>：ESP-IDF flash（读取 .idfconfig.yaml 中的 serial_port）
vim.keymap.set("n", "<F6>", function()
    local root = find_sdkconfig_root()
    if not root then
        return vim.notify("F6 只在 ESP-IDF 项目中有效", vim.log.levels.INFO)
    end

    -- 配置文件必须是项目根的 .idfconfig.yaml
    local cfgpath = root .. "/.idfconfig.yaml"
    local port_opt = ""
    if uv.fs_stat(cfgpath) then
        local cfg = parse_idfconfig(cfgpath)
        if cfg.serial_port then
            port_opt = " -p " .. vim.fn.shellescape(cfg.serial_port)
        end
    end

    -- 切到项目根再执行 flash
    send_to_term("cd " .. vim.fn.shellescape(root) .. " && idf.py" .. port_opt .. " flash")
end, { desc = "F6 → ESP-IDF Flash" })

vim.keymap.set("n", "<F7>", "<cmd>LspRestart<CR>", { desc = "Restart LSP" })
