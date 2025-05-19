-- lua/plugins/project.lua
return {
    {
        "ahmedkhalf/project.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            detection_methods = { "pattern" },
            patterns = { ".git", "CMakeLists.txt", "Makefile" },
        },
    },

    {
        "akinsho/toggleterm.nvim",
        version = "*",
        -- 只在 VeryLazy 阶段加载，不要马上打开
        event = "VeryLazy",
        config = function()
            require("toggleterm").setup({
                size = 15,
                open_mapping = false, -- 我们自己绑定 F5
                direction = "horizontal",
                close_on_exit = false,
                persist_size = true,
            })
        end,
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        dependencies = { "ahmedkhalf/project.nvim", "akinsho/toggleterm.nvim" },
        config = function()
            require("which-key").setup({})
            -- 下面这行指向你的 f5 映射脚本
            require("config.f5")
        end,
    },
}
