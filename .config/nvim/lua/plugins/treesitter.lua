return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",

	config = function()
		require("nvim-treesitter").setup()

		-- Parser names (!!!not same as FILETYPES)
		require("nvim-treesitter").install({
			"lua",
			"c",
			"c_sharp",
			"python",
			"java",
			"javascript",
			"tsx",
			"typescript",
			"css",
			"html",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"lua",
				"c",
				"cs",
				"python",
				"java",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"css",
				"html",
			},
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})

		-- Treesitter-based indentation
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"lua",
				"c",
				"cs",
				"python",
				"java",
				"javascript",
				"css",
				"html",
			},
			callback = function(args)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
