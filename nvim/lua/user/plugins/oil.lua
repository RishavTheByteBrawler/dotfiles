return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("oil").setup({
			view_options = {
				show_hidden = true,
			},
			float = {
				padding = 2,
				max_width = 100,
				max_height = 30,
				border = "rounded", -- You can change to "single", "double", etc.
				win_options = {
					winblend = 0,
				},
			},
			default_file_explorer = false,
			columns = {
				"icon",
			},
		})

		-- Optional: keybind to open oil in floating window with <leader>o
		vim.keymap.set("n", "<leader>o", require("oil").toggle_float, { desc = "Open Oil (floating)" })
	end,
}
