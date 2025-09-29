require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)
local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

lspconfig.ruff.setup({
  on_attach = on_attach,  -- Same as Pyright
  capabilities = capabilities,
  init_options = {
    settings = {
      -- Ruff-specific settings (optional)
      args = { "--quiet" },  -- Suppress unnecessary output
    },
  },
})

lspconfig.clangd.setup({
  on_attach = on_attach,  -- Same as Pyright
  capabilities = capabilities,
  init_options = {
    settings = {
    },
  },
})

-- read :h vim.lsp.config for changing options of lsp servers 
