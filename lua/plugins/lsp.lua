return {
    {
        -- 第一个插件定义
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                ruff = {
                    cmd_env = { RUFF_TRACE = "messages" },
                    init_options = {
                        settings = {
                            logLevel = "error",
                        },
                    },
                    keys = {
                        {
                            "<leader>co",
                            LazyVim.lsp.action["source.organizeImports"],
                            desc = "Organize Imports",
                        },
                    },
                },
                ruff_lsp = {
                    keys = {
                        {
                            "<leader>co",
                            LazyVim.lsp.action["source.organizeImports"],
                            desc = "Organize Imports",
                        },
                    },
                },
                pyright = {
                    settings = {
                        python = {
                            analysis = {
                                autoSearchPaths = true,
                                diagnosticMode = "openFilesOnly",
                                -- diagnosticMode = "off",
                                -- useLibraryCodeForTypes = true,
                                -- useLibraryCodeForTypes = false,
                                typeCheckingMode = "basic",
                                -- typeCheckingMode = "off",
                            },
                        },
                    },
                },
            },
            -- setup = {
            --   ["ruff"] = function()
            --     LazyVim.lsp.on_attach(function(client, _)
            --       -- Disable hover in favor of Pyright
            --       client.server_capabilities.hoverProvider = false
            --       -- client.server_capabilities.hoverProvider = true
            --     end, "ruff")
            --   end,
            -- },
        },
    },
    {
        -- 第二个插件定义(合并到同一个 neovim/nvim-lspconfig)
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            local servers = { "pyright", "basedpyright", "ruff", "ruff_lsp" }
            for _, server in ipairs(servers) do
                -- 没有则初始化
                opts.servers[server] = opts.servers[server] or {}
                -- 如果想同时启用 pyright、ruff、ruff_lsp，就写下面这样
                opts.servers[server].enabled = (server == "pyright") or (server == "ruff") or (server == "ruff_lsp")
                -- opts.servers[server].enabled = (server == "ruff") or (server == "ruff_lsp")
            end
        end,
    },

    {
        "kristijanhusak/vim-dadbod-completion",
        dependencies = "vim-dadbod",
        ft = sql_ft,
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = sql_ft,
                callback = function()
                    if LazyVim.has("nvim-cmp") then
                        local cmp = require("cmp")

                        -- global sources
                        ---@param source cmp.SourceConfig
                        local sources = vim.tbl_map(function(source)
                            return { name = source.name }
                        end, cmp.get_config().sources)

                        -- add vim-dadbod-completion source
                        table.insert(sources, { name = "vim-dadbod-completion" })

                        -- update sources for the current buffer
                        cmp.setup.buffer({ sources = sources })
                    end
                end,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- bacon_ls = {
                --   enabled = diagnostics == "bacon-ls",
                -- },
                rust_analyzer = { enabled = true },
            },
        },
    },
}
