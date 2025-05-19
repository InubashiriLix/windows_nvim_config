local util = require("lspconfig.util")

-- 1) ESP-Clangd 可执行
local clangd_path = "E:/1-03_Espressif/Espressif/tools/esp-clang/" .. "esp-18.1.2_20240912/esp-clang/bin/clangd.exe"
-- 2) 对应的 clang 驱动
local clang_driver = clangd_path:gsub("clangd.exe$", "clang.exe")
-- 3) 真正编译 ESP32-S3 的 Xtensa GCC 前端
local xtensa_driver = "E:/1-03_Espressif/Espressif/tools/xtensa-esp-elf/"
    .. "esp-14.2.0_20241119/xtensa-esp-elf/bin/xtensa-esp32s3-elf-gcc.exe"

return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            clangd = {
                cmd = {
                    clangd_path,
                    "--background-index",
                    "--clang-tidy",
                    "--all-scopes-completion",
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                    "--pch-storage=disk",
                    "--log=verbose", -- 验证阶段用 verbose，之后可改回 error
                    "--j=5",
                    "--compile-commands-dir=build", -- 加载 compile_commands.json
                    "--query-driver=" .. clang_driver, -- 允许用 esp-clang 的 clang.exe
                    "--query-driver=" .. xtensa_driver, -- 允许用 Xtensa GCC 前端
                },
                root_dir = util.root_pattern("sdkconfig", "CMakeLists.txt"),
            },
        },
    },
}

-- NOTE: remember to add these content in your esp-idf project as .clangd file
-- CompileFlags:
--   CompilationDatabase: build
--   Remove:
--     - "-fno-tree-switch-conversion"
--     - "-fno-shrink-wrap"
--     - "-fstrict-volatile-bitfields"
--     - "-mlongcalls"
--     - "-mtext-section-literals"
--     - "-fno-builtin-memcpy"
--     - "-fno-builtin-memset"
--     - "-fno-builtin-bzero"
--     - "-fno-builtin-stpcpy"
--     - "-fno-builtin-strncpy"
--     - "-march=rv32imac_zicsr_zifencei"
--
