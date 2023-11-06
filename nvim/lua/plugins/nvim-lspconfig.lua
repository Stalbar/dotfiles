local config = function()
  require("neoconf").setup({})
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local lspconfig = require("lspconfig")
	local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = "" }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	local on_attach = function(client, bufnr)
		local opts = { noremap = true, silent = true, buffer = bufnr }

		vim.keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", opts)
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
		vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.bif.implementation()<CR>", opts)
		vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
		vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
		vim.keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
		vim.keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
		vim.keymap.set("n", "<leader>pd", "<cmd>Lspsaga diagnostics_jump_prev<CR>", opts)
		vim.keymap.set("n", "<leader>nd", "<cmd>Lspsaga diagnostics_jump_next<CR>", opts)
		vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
		vim.keymap.set("n", "<leader>lo", "<cmd>LSoutlineToggle<CR>", opts)
	end
  
  local capabilities = cmp_nvim_lsp.default_capabilities()

	-- lua
	lspconfig.lua_ls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
				},
			},
		},
	})

  lspconfig.csharp_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })  

  
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")
  -- local semgrep = require("efmls-configs.linters.semgrep")
  -- local csharpier = require("efmls-configs.formatters.csharpier") 
	-- efm config
	lspconfig.efm.setup({
		filetypes = {
			"lua",
      -- "cs",
		},
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = true,
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},
		settings = {
			languages = {
				lua = { luacheck, stylua },
        -- cs = { csharpier },
			},
		},
	})

	-- Format on Save
	local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = lsp_fmt_group,
		callback = function()
			local efm = vim.lsp.get_active_clients({ name = "efm" })

			if vim.tbl_isempty(efm) then
				return
			end

			vim.lsp.buf.format({ name = "efm" })
		end,
	})
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	lazy = false,
	dependencies = {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-nvim-lsp",
		"windwp/nvim-autopairs",
		"williamboman/mason.nvim",
		"creativenull/efmls-configs-nvim",
	},
}
