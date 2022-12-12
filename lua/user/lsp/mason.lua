local servers = {
	"sumneko_lua",
	-- "cssls",
	-- "html",
	-- "tsserver",
	"pyright",
	-- "bashls",
	"jsonls",
	-- "yamlls",
	"rust_analyzer",
	"vimls",
  "html",
}

-- UI for Mason
local settings = {
	ui = {
		border = "none",
		icons = {
			package_installed = "◍",
			package_pending = "◍",
			package_uninstalled = "◍",
		},
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4,
}

-- Setup Mason
require("mason").setup(settings)

-- Set mason-lspconfig, install all LSP servers
require("mason-lspconfig").setup({
	ensure_installed = servers,
	automatic_installation = true,
})

-- Import lspconfig
local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

local opts = {}

for _, server in pairs(servers) do
	opts = {
		on_attach = require("user.lsp.handlers").on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
	}

	server = vim.split(server, "@")[1]

	local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server)
	if require_ok then
		opts = vim.tbl_deep_extend("force", conf_opts, opts)
	end

	if server == "rust_analyzer" then
		require("rust-tools").setup({
			server = {
				on_attach = require("user.lsp.handlers").on_attach,
				capabilities = require("user.lsp.handlers").capabilities,
			},
		})
		goto continue
	end

	lspconfig[server].setup(opts)
	::continue::
end
