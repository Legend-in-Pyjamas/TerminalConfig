--local function enable_transparency()
--  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--end

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000, -- ...load colorscheme before other plugins
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
		config = function(_, opts)
			-- setup() must run before the colorscheme is applied
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			options = {
				theme = "tokyonight",
			},
		},
	},
}
