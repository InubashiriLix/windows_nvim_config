-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "kk", "<Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "kj", "<Esc>", { noremap = true, silent = true })

-- ~/.config/nvim/lua/config/keymaps.lua
-- fucking update delete the windows split shit
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>wq", "<C-w>q", { desc = "Close current window" })

vim.api.nvim_create_user_command("RunSQL", function()
    -- 获取当前缓冲区的内容
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    -- 拼接为一个完整的 SQL 查询
    local query = table.concat(lines, "\n")

    -- 创建或获取下方输出窗口
    local function get_or_create_output_win()
        -- 尝试找到现有的名为 "SQL Output" 的缓冲区
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(buf):match("SQL Output") then
                -- 如果找到匹配的缓冲区，返回其窗口 ID
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(win) == buf then
                        return win, buf
                    end
                end
            end
        end

        -- 如果没有找到，创建新窗口和缓冲区
        vim.cmd("belowright split")
        local new_buf = vim.api.nvim_create_buf(false, true) -- 创建新缓冲区
        vim.api.nvim_buf_set_name(new_buf, "SQL Output") -- 设置缓冲区名称
        vim.api.nvim_win_set_buf(0, new_buf) -- 将缓冲区关联到当前窗口
        vim.api.nvim_buf_set_option(new_buf, "modifiable", true) -- 确保缓冲区可编辑
        return 0, new_buf
    end

    local output_win, output_buf = get_or_create_output_win()

    -- 清空输出缓冲区
    vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, { "Running query..." })

    -- 使用 jobstart 执行查询
    vim.fn.jobstart("echo '" .. query .. "' | vim +DBExec", {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                -- 将结果追加到缓冲区
                vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, data)
            end
        end,
        on_stderr = function(_, data)
            if data then
                -- 将错误信息追加到缓冲区
                vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, { "Error: " .. table.concat(data, "\n") })
            end
        end,
        on_exit = function(_, _)
            -- 告知用户查询完成
            vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, { "Query completed!" })
        end,
    })
end, {})

-- 设置快捷键
vim.api.nvim_set_keymap(
    "n",
    "<leader>r",
    ":RunSQL<CR>",
    { noremap = true, silent = true, desc = "Run SQL query buffer" }
)

-- run sql in buffer now
-- vim.api.nvim_set_keymap("n", "<F10>", ":w<CR>:lua RunMySQL()<CR>", { noremap = true, silent = true })
--
-- function RunMySQL()
--   local file = vim.fn.expand("%") -- 获取当前文件路径
--   local cmd = string.format("mysql -u root --password=Lix0123456789 < %s", file)
--   vim.cmd("split") -- 打开一个新窗口
--   vim.fn.termopen(cmd) -- 在终端中运行命令
-- end

--
-- 绑定快捷键
vim.api.nvim_set_keymap("n", "<F10>", ":w<CR>:lua RunMySQL()<CR>", { noremap = true, silent = true })

-- 定义运行 MySQL 查询的函数
function RunMySQL()
    local file = vim.fn.expand("%") -- 获取当前文件路径
    local cmd = string.format('mysql -u root --password=Lix0123456789 < "%s"', file)

    -- 检查是否已有浮动窗口
    if vim.g.mysql_float_win and vim.api.nvim_win_is_valid(vim.g.mysql_float_win) then
        -- 如果窗口已存在，直接切换到该窗口
        vim.api.nvim_set_current_win(vim.g.mysql_float_win)
    else
        -- 创建新的浮动窗口
        local buf = vim.api.nvim_create_buf(true, true) -- 创建不可修改的临时缓冲区
        local width = math.floor(vim.o.columns * 0.4) -- 窗口宽度为屏幕的 40%
        local height = math.floor(vim.o.lines * 0.3) -- 窗口高度为屏幕的 30%
        local row = vim.o.lines - height - 2 -- 固定在右下角
        local col = vim.o.columns - width - 2

        -- 配置浮动窗口的布局
        local opts = {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            style = "minimal",
            border = "rounded", -- 设置边框样式为圆角
        }

        -- 打开浮动窗口并保存其 ID
        vim.g.mysql_float_win = vim.api.nvim_open_win(buf, true, opts)
        vim.g.mysql_float_buf = buf -- 保存缓冲区 ID

        -- 设置浮动窗口不可修改
        vim.api.nvim_buf_set_option(buf, "modifiable", true)
    end

    -- 在浮动窗口中运行 MySQL 命令
    vim.fn.termopen(cmd, {
        on_exit = function(_, exit_code, _)
            if exit_code == 0 then
                print("SQL query executed successfully!")
            else
                print("SQL query failed. Check the output for details.")
            end
        end,
    })
end

vim.api.nvim_set_keymap("n", "<F9>", ":lua CloseMySQLWindow()<CR>", { noremap = true, silent = true })

function CloseMySQLWindow()
    if vim.g.mysql_float_win and vim.api.nvim_win_is_valid(vim.g.mysql_float_win) then
        vim.api.nvim_win_close(vim.g.mysql_float_win, true)
        vim.g.mysql_float_win = nil
        vim.g.mysql_float_buf = nil
    else
        print("No active MySQL window to close.")
    end
end
