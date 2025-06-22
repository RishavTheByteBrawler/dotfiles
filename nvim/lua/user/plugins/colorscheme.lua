return {
    "tiagovla/tokyodark.nvim",
    opts = {
        transparent_background = false, -- Keep your existing setting
        gamma = 1.00, -- Adjust brightness if needed (optional)
        custom_highlights = function(highlights, palette)
            return {
                -- Override Visual mode selection color
                Visual = { bg = "#4a5568" }, -- A brighter grayish-blue for better contrast
                VisualNOS = { bg = "#4a5568" }, -- Same for non-owning selections
                -- Override Diagnostic colors
                DiagnosticError = { fg = "#ff3333" }, -- Bright red for errors
                DiagnosticWarn = { fg = "#ffff00" }, -- Bright yellow for warnings
            }
        end,
        custom_palette = function(palette)
            -- Optionally override palette colors if needed
            return {
                error = "#ff3333", -- Bright red for error signs/icons
                warning = "#ffff00", -- Bright yellow for warning signs/icons
            }
        end,
    },
    config = function(_, opts)
        require("tokyodark").setup(opts)
        vim.cmd([[colorscheme tokyodark]])
    end,
}
