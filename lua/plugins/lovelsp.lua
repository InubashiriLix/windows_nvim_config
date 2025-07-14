return {
    -- ① 带 LuaCATS 类型注解的 LÖVE API
    {
        "love2d-community/love-api",
        name = "love_api", -- 给个别名，其他插件引用方便
    },

    -- ② 覆写 lspconfig 的 opts，把 love-api 加进 workspace
    {
        "neovim/nvim-lspconfig",
        dependencies = { "love_api" },
        opts = function(_, opts) -- opts 已含 LazyVim 默认 LSP 配置
            local love_path = vim.fn.stdpath("data") .. "/lazy/love_api/lua"

            -- 如果原先 opts 里没有 lua_ls，先准备一个空表
            opts.lua_ls = opts.lua_ls or {}

            -- 深度合并，保留 LazyVim 自带设置，只添加/覆盖需要的字段
            opts.lua_ls.settings = vim.tbl_deep_extend("force", opts.lua_ls.settings or {}, {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim", "love" } },
                    workspace = {
                        checkThirdParty = false,
                        preloadFileSize = 2000,
                        library = { [love_path] = true },
                    },
                    completion = { callSnippet = "Replace" },
                },
            })
        end,
    },

    -- ③ 可选：热重载/一键运行 LÖVE
    {
        "S1M0N38/love2d.nvim",
        ft = "lua",
        opts = { live_reload = true },
    },
}
