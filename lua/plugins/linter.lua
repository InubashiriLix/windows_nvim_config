return {
  "mfussenegger/nvim-lint",
  opts = {
    linters = {
      sqlfluff = {
        args = {
          "lint",
          "--format=json", -- 使用 JSON 格式
          "--dialect=postgres",
        },
      },
    },
  },
}
