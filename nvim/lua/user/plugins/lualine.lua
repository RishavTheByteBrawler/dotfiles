return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count
		local p = require("tokyodark.palette")
		local colors = {
			bg = p.bg1,
			fg = p.fg,
			red = p.red,
			green = p.green,
			yellow = p.yellow,
			blue = p.blue,
			purple = p.purple,
			cyan = p.cyan,
			grey = p.grey,
		}

		local tokyo_dark = {
			inactive = {
				a = { fg = colors.grey, bg = colors.bg, gui = "bold" },
				b = { fg = colors.grey, bg = colors.bg },
				c = { fg = colors.grey, bg = colors.bg },
				x = { fg = colors.grey, bg = colors.bg },
				y = { fg = colors.grey, bg = colors.bg },
				z = { fg = colors.grey, bg = colors.bg },
			},
			normal = {
				a = { fg = colors.bg, bg = colors.green, gui = "bold" },
				b = { fg = colors.fg, bg = colors.bg },
				c = { fg = colors.fg, bg = colors.bg },
				x = { fg = colors.fg, bg = colors.bg },
				y = { fg = colors.fg, bg = colors.bg },
				z = { fg = colors.bg, bg = colors.green, gui = "bold" },
			},
			visual = { a = { fg = colors.bg, bg = colors.purple, gui = "bold" } },
			replace = { a = { fg = colors.bg, bg = colors.red, gui = "bold" } },
			insert = { a = { fg = colors.bg, bg = colors.blue, gui = "bold" } },
			command = { a = { fg = colors.bg, bg = colors.yellow, gui = "bold" } },
		}

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				theme = tokyo_dark,
			},
			sections = {
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64" },
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
