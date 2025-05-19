return {
  -- 数据库核心插件
  { "tpope/vim-dadbod", cmd = "DB" },

  -- 数据库 UI 界面
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = "vim-dadbod",
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
    },
    init = function()
      local data_path = vim.fn.stdpath("data")

      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
      vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_use_nvim_notify = true
      vim.g.db_ui_execute_on_save = false
    end,
  },

  -- 数据库补全
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = "vim-dadbod",
    ft = { "sql" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql" },
        callback = function()
          if require("lazy.core.config").plugins["nvim-cmp"] then
            local cmp = require("cmp")
            local sources = cmp.get_config().sources
            table.insert(sources, { name = "vim-dadbod-completion" })
            cmp.setup.buffer({ sources = sources })
          end
        end,
      })
    end,
  },
}
