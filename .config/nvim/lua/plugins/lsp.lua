return {
	'neovim/nvim-lspconfig',
	dependencies = {
		{ 'mason-org/mason.nvim', opts = {} },
		'mason-org/mason-lspconfig.nvim',

		-- Autocompletion
		'hrsh7th/nvim-cmp',
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-path',
		'saadparwaiz1/cmp_luasnip',
		'hrsh7th/cmp-nvim-lsp',

		-- Snippets
		'L3MON4D3/LuaSnip',
		'rafamadriz/friendly-snippets',
	},
	config = function()
		local autoformat_filetypes = {
			'lua',
		}

		-- Rounded borders on floating windows
		vim.o.winborder = 'rounded'

		-- Autoformat on save for the filetypes listed above
		vim.api.nvim_create_autocmd('LspAttach', {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then return end

				if vim.tbl_contains(autoformat_filetypes, vim.bo[args.buf].filetype) then
					-- one augroup per buffer so re-attaching doesn't stack up autocmds
					local group = vim.api.nvim_create_augroup('LspAutoformat' .. args.buf,
						{ clear = true })
					vim.api.nvim_create_autocmd('BufWritePre', {
						group = group,
						buffer = args.buf,
						callback = function()
							vim.lsp.buf.format({
								bufnr = args.buf,
								id = client.id,
							})
						end,
					})
				end
			end,
		})

		-- Diagnostics UI
		vim.diagnostic.config({
			virtual_text = true,
			severity_sort = true,
			float = {
				style = 'minimal',
				header = '',
				prefix = '',
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = '✗',
					[vim.diagnostic.severity.WARN] = '▲',
					[vim.diagnostic.severity.HINT] = '⚑',
					[vim.diagnostic.severity.INFO] = '»',
				},
			},
		})

		-- Give every server cmp's extra capabilities
		vim.lsp.config('*', {
			capabilities = require('cmp_nvim_lsp').default_capabilities(),
		})

		-- Keymaps
		vim.api.nvim_create_autocmd('LspAttach', {
			callback = function(event)
				local opts = { buffer = event.buf }

				vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
				vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
				vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
				vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
				vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
				vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
				vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
				vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
				vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
				vim.keymap.set({ 'n', 'x' }, '<F3>', function()
					vim.lsp.buf.format({ async = true })
				end, opts)
				vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
			end,
		})

		-- Per-server overrides
		vim.lsp.config('lua_ls', {
			settings = {
				Lua = {
					runtime = { version = 'LuaJIT' },
					diagnostics = { globals = { 'vim' } },
					workspace = { library = { vim.env.VIMRUNTIME } },
				},
			},
		})

		require('mason-lspconfig').setup({
			ensure_installed = {
				'lua_ls',
				'intelephense',
				'ts_ls',
				'eslint',
			},
			automatic_enable = true,
		})

		-- Completion (nvim-cmp)
		local cmp = require('cmp')

		require('luasnip.loaders.from_vscode').lazy_load()

		vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

		cmp.setup({
			preselect = 'item',
			completion = {
				completeopt = 'menu,menuone,noinsert',
			},
			window = {
				documentation = cmp.config.window.bordered(),
			},
			sources = {
				{ name = 'path' },
				{ name = 'nvim_lsp' },
				{ name = 'buffer',  keyword_length = 3 },
				{ name = 'luasnip', keyword_length = 2 },
			},
			snippet = {
				expand = function(args)
					require('luasnip').lsp_expand(args.body)
				end,
			},
			formatting = {
				fields = { 'abbr', 'menu', 'kind' },
				format = function(entry, item)
					local n = entry.source.name
					if n == 'nvim_lsp' then
						item.menu = '[LSP]'
					else
						item.menu = string.format('[%s]', n)
					end
					return item
				end,
			},
			mapping = cmp.mapping.preset.insert({
				-- confirm completion item
				['<CR>'] = cmp.mapping.confirm({ select = false }),

				-- scroll documentation window
				['<C-f>'] = cmp.mapping.scroll_docs(5),
				['<C-u>'] = cmp.mapping.scroll_docs(-5),

				-- toggle completion menu
				['<C-e>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.abort()
					else
						cmp.complete()
					end
				end),

				-- tab complete
				['<Tab>'] = cmp.mapping(function(fallback)
					local col = vim.fn.col('.') - 1

					if cmp.visible() then
						cmp.select_next_item({ behavior = 'select' })
					elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
						fallback()
					else
						cmp.complete()
					end
				end, { 'i', 's' }),

				-- go to previous item
				['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),

				-- navigate to next snippet placeholder
				['<C-d>'] = cmp.mapping(function(fallback)
					local luasnip = require('luasnip')

					if luasnip.jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { 'i', 's' }),

				-- navigate to the previous snippet placeholder
				['<C-b>'] = cmp.mapping(function(fallback)
					local luasnip = require('luasnip')

					if luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { 'i', 's' }),
			}),
		})
	end,
}
