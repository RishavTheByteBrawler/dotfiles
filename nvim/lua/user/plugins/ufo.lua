local M = {
	"kevinhwang91/nvim-ufo",
	dependencies = { "kevinhwang91/promise-async" },
	event = "BufReadPost", -- Lazy load on buffer read for better performance
	opts = {
		-- Exclude specified filetypes from UFO
		filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
		-- Use treesitter and indent as fold providers
		provider_selector = function(bufnr, filetype, buftype)
			return { "treesitter", "indent" }
		end,
		-- Customize fold indicators
		fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
			local newVirtText = {}
			local suffix = (" \t➤ %d lines "):format(endLnum - lnum)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0

			for _, chunk in ipairs(virtText) do
				local chunkText = chunk[1]
				local chunkWidth = vim.fn.strdisplaywidth(chunkText)
				if targetWidth > curWidth + chunkWidth then
					table.insert(newVirtText, chunk)
				else
					chunkText = truncate(chunkText, targetWidth - curWidth)
					local newChunk = { chunkText, chunk[2] }
					table.insert(newVirtText, newChunk)
					break
				end
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { suffix, "MoreMsg" })
			return newVirtText
		end,
		-- Enable preview window for fold contents
		preview = {
			win_config = {
				border = "rounded",
				winhighlight = "Normal:Normal,FloatBorder:Normal",
				maxheight = 20,
			},
		},
	},
	config = function(_, opts)
		-- Set fold indicators: right arrow for closed, down arrow for open
		vim.o.foldcolumn = "1" -- Show fold column
		vim.o.foldlevel = 99 -- Start with all folds open
		vim.o.foldlevelstart = 99 -- Ensure files open with all folds expanded
		vim.o.foldenable = true -- Enable folding
		vim.o.fillchars = [[eob: ,fold: ,foldopen:▼,foldclose:▶,foldsep:│]]

		-- Clear Folded highlight to avoid background/foreground highlighting
		vim.api.nvim_set_hl(0, "Folded", { bg = "NONE", fg = "NONE" })

		-- Detach UFO for excluded filetypes
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("local_detach_ufo", { clear = true }),
			pattern = opts.filetype_exclude,
			callback = function()
				require("ufo").detach()
			end,
		})

		-- Setup UFO with provided options
		require("ufo").setup(opts)

		-- Optional keymaps for fold navigation and preview
		vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
		vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
		vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with level" })
		vim.keymap.set("n", "zp", require("ufo").peekFoldedLinesUnderCursor, { desc = "Peek folded lines" })
	end,
}

return M
