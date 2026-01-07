require("nvchad.configs.lspconfig").defaults()

local util = require 'lspconfig.util'
local async = require 'lspconfig.async'

local function is_library(fname)
  local user_home = vim.fs.normalize(vim.env.HOME)
  local cargo_home = os.getenv 'CARGO_HOME' or user_home .. '/.cargo'
  local registry = cargo_home .. '/registry/src'
  local git_registry = cargo_home .. '/git/checkouts'

  local rustup_home = os.getenv 'RUSTUP_HOME' or user_home .. '/.rustup'
  local toolchains = rustup_home .. '/toolchains'

  for _, item in ipairs { toolchains, registry, git_registry } do
    if util.path.is_descendant(item, fname) then
      local clients = vim.lsp.get_clients { name = 'rust_analyzer' }
      return #clients > 0 and clients[#clients].config.root_dir or nil
    end
  end
end

local servers = { "html", "cssls", "pyright", "rust_analyzer" }
vim.lsp.enable(servers)

vim.lsp.config('pyright', {
  on_attach = function (client, bufnr)
    vim.api.nvim__buf_create_user_command(bufnr, 'LspPyrightOrganizeImports', function ()
      local params = {
        command = 'pyright.organizeimports',
        arguments = { vim.uri_from_bufnr(bufnr),}
      }
      client.request('workspace/executeCommand', params, nil, bufnr)
    end, {
        desc = 'Organize Imports',
      })
  end,
  settings = {
    python = {
      autoSearchPaths = true,
      useLibraryCodeForTypes = true,
      diagnosticMode = 'openFilesOnly',
    },
  },
})

-- vim.lsp.config('clangd', {
--   cmd = { 'clangd' },
--   filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda'},
--   root_markers = {
--     '.clangd',
--     '.clangd-tidy',
--     '.clangd-format',
--     'compile_commands.json',
--     'compile_flags.txt',
--     'configure.ac',
--     '.git',
--   },
-- })

vim.lsp.config('rust_analyzer', {
  default_config = {
    cmd = { 'rust_analyzer' },
    filetypes = { 'rust' },
    single_file_support = true,
    root_dir = function (fname)
      local reuse_active = is_library(fname)
      if reuse_active then
        return reuse_active
      end

      local cargo_crate_dir = util.root_pattern 'Cargo.toml'(fname)
      local cargo_workspace_root

      if cargo_crate_dir ~= nil then
        local cmd = {
          'cargo', 'metadata', '--no-deps', '--format-version', '1', '--manifest-path',
          cargo_crate_dir .. '/Cargo.toml',
        }

        local result = async.run_command(cmd)

        if result and result[1] then
          result = vim.json.decode(table.concat(result, ''))
          if result['workspace_root'] then
            cargo_workspace_root = vim.fs.normalize(result['workspace_root'])
          end
        end
      end
      return cargo_workspace_root
        or cargo_crate_dir
        or util.root_pattern 'rust_project.json'(fname)
        or vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true})[1])
    end,
    capabilities = {
      experimental = {
        serverStatusNotification = true,
      },
    },
  }
})
-- read :h vim.lsp.config for changing options of lsp servers 
