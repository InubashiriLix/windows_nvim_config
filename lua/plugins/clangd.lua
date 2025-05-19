return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- clangd = { mason = true, cmd = { "clangd", "--header-insertion=never" } },
				clangd = {
					mason = false,
					cmd = {
						"clangd-17",
						"--background-index",
						"--suggest-missing-includes",
						"--header-insertion=never",
						"--compile-commands-dir=build",
					},
					root_dir = require("lspconfig.util").root_pattern("CMakeLists.txt", ".git"),
					includePath = {
						"/opt/ros/humble/include/",
						"/usr/include/c++/11/",
						"/usr/include/aarch64-linux-gnu/c++/11/",
						"/usr/include/c++/11/backward/",
						"/usr/lib/gcc/aarch64-linux-gnu/11/include/",
						"/usr/local/include/",
						"/usr/include/aarch64-linux-gnu/",
						"/usr/include/",
					},
				},
			},
		},
	},
}
