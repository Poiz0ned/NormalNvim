-- Dev core
-- Things that are just there.

--    Sections:
--       ## TREE SITTER
--       -> nvim-treesitter                [syntax highlight]
--       -> nvim-ts-autotag                [treesitter understand html tags]
--       -> nvim-ts-context-commentstring  [treesitter comments]
--       -> nvim-colorizer                 [hex colors]

--       ## LSP
--       -> nvim-java                      [java support]
--       -> mason-lspconfig                [auto start lsp]
--       -> nvim-lspconfig                 [lsp configs]
--       -> mason.nvim                     [lsp package manager]
--       -> SchemaStore.nvim               [lsp schema manager]
--       -> none-ls                        [lsp code formatting]
--       -> neodev                         [lsp for nvim lua api]
--       -> garbage-day                    [lsp garbage collector]

--       ## AUTO COMPLETION
--       -> nvim-cmp                       [auto completion engine]
--       -> cmp-nvim-buffer                [auto completion buffer]
--       -> cmp-nvim-path                  [auto completion path]
--       -> cmp-nvim-lsp                   [auto completion lsp]
--       -> cmp-luasnip                    [auto completion snippets]

local utils = require("base.utils")
local utils_lsp = require("base.utils.lsp")

return {
  --  TREE SITTER ---------------------------------------------------------
  --  [syntax highlight] + [treesitter understand html tags] + [comments]
  --  https://github.com/nvim-treesitter/nvim-treesitter
  --  https://github.com/windwp/nvim-ts-autotag
  --  https://github.com/windwp/nvim-treesitter-textobjects
  --  https://github.com/JoosepAlviste/nvim-ts-context-commentstring
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "windwp/nvim-ts-autotag",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    event = "User BaseFile",
    cmd = {
      "TSBufDisable",
      "TSBufEnable",
      "TSBufToggle",
      "TSDisable",
      "TSEnable",
      "TSToggle",
      "TSInstall",
      "TSInstallInfo",
      "TSInstallSync",
      "TSModuleInfo",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
    },
    build = ":TSUpdate",
    opts = {
      auto_install = false, -- Currently bugged. Use [:TSInstall all] and [:TSUpdate all]
      autotag = { enable = true },
      highlight = {
        enable = true,
        disable = function(_, bufnr) return utils.is_big_file(bufnr) end,
      },
      matchup = {
        enable = true,
        enable_quotes = true,
        disable = function(_, bufnr) return utils.is_big_file(bufnr) end,
      },
      incremental_selection = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ak"] = { query = "@block.outer", desc = "around block" },
            ["ik"] = { query = "@block.inner", desc = "inside block" },
            ["ac"] = { query = "@class.outer", desc = "around class" },
            ["ic"] = { query = "@class.inner", desc = "inside class" },
            ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
            ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
            ["af"] = { query = "@function.outer", desc = "around function " },
            ["if"] = { query = "@function.inner", desc = "inside function " },
            ["al"] = { query = "@loop.outer", desc = "around loop" },
            ["il"] = { query = "@loop.inner", desc = "inside loop" },
            ["aa"] = { query = "@parameter.outer", desc = "around argument" },
            ["ia"] = { query = "@parameter.inner", desc = "inside argument" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]k"] = { query = "@block.outer", desc = "Next block start" },
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]a"] = { query = "@parameter.inner", desc = "Next parameter start" },
          },
          goto_next_end = {
            ["]K"] = { query = "@block.outer", desc = "Next block end" },
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]A"] = { query = "@parameter.inner", desc = "Next parameter end" },
          },
          goto_previous_start = {
            ["[k"] = { query = "@block.outer", desc = "Previous block start" },
            ["[f"] = { query = "@function.outer", desc = "Previous function start" },
            ["[a"] = { query = "@parameter.inner", desc = "Previous parameter start" },
          },
          goto_previous_end = {
            ["[K"] = { query = "@block.outer", desc = "Previous block end" },
            ["[F"] = { query = "@function.outer", desc = "Previous function end" },
            ["[A"] = { query = "@parameter.inner", desc = "Previous parameter end" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            [">K"] = { query = "@block.outer", desc = "Swap next block" },
            [">F"] = { query = "@function.outer", desc = "Swap next function" },
            [">A"] = { query = "@parameter.inner", desc = "Swap next parameter" },
          },
          swap_previous = {
            ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
            ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
            ["<A"] = { query = "@parameter.inner", desc = "Swap previous parameter" },
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      require('ts_context_commentstring').setup(
        { enable = true, enable_autocmd = false })      -- Enable commentstring
      vim.g.skip_ts_context_commentstring_module = true -- Increase performance
    end,
  },

  --  [hex colors]
  --  https://github.com/NvChad/nvim-colorizer.lua
  {
    "NvChad/nvim-colorizer.lua",
    event = "User BaseFile",
    cmd = {
      "ColorizerToggle",
      "ColorizerAttachToBuffer",
      "ColorizerDetachFromBuffer",
      "ColorizerReloadAllBuffers",
    },
    opts = { user_default_options = { names = false } },
  },

  --  LSP -------------------------------------------------------------------

  -- nvim-java [java support]
  -- https://github.com/nvim-java/nvim-java
  -- Reliable jdtls support. Must go before mason-lspconfig nad lsp-config.
  {
    'nvim-java/nvim-java',
    ft = { "java" },
    dependencies = {
      'nvim-java/lua-async-await',
      'nvim-java/nvim-java-core',
      'nvim-java/nvim-java-test',
      'nvim-java/nvim-java-dap',
      'MunifTanjim/nui.nvim',
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',
      {
        'williamboman/mason.nvim',
        opts = {
          registries = {
            'github:nvim-java/mason-registry',
            'github:mason-org/mason-registry',
          },
        },
      }
    },
  },

  --  nvim-lspconfig [lsp configs]
  --  https://github.com/neovim/nvim-lspconfig
  --  This plugin provide default configs for the lsp servers available on mason.
  {
    "neovim/nvim-lspconfig",
    event = "User BaseFile",
  },

  -- mason-lspconfig [auto start lsp]
  -- https://github.com/williamboman/mason-lspconfig.nvim
  -- This plugin auto starts the lsp servers installed by Mason
  -- every time Neovim trigger the event FileType.
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    event = "User BaseFile",
    opts = function(_, opts)
      if not opts.handlers then opts.handlers = {} end
      opts.handlers[1] = function(server) utils_lsp.setup(server) end
    end,
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      utils_lsp.apply_default_lsp_settings() -- Apply our default lsp settings.
      utils.trigger_event("FileType")        -- This line starts this plugin.
    end,
  },

  --  mason [lsp package manager]
  --  https://github.com/williamboman/mason.nvim
  {
    "williamboman/mason.nvim",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate",
      "MasonUpdateAll",
    },
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_uninstalled = "✗",
          package_pending = "⟳",
        },
      },
    },
    build = ":MasonUpdate",
    config = function(_, opts)
      local updater = require("distroupdate.utils.mason")
      require("mason").setup(opts)
      local cmd = vim.api.nvim_create_user_command
      cmd("MasonUpdate", function(options) updater.update(options.fargs) end, {
        nargs = "*",
        desc = "Update Mason Package",
        complete = function(arg_lead)
          local _ = require "mason-core.functional"
          return _.sort_by(
            _.identity,
            _.filter(_.starts_with(arg_lead), require("mason-registry").get_installed_package_names())
          )
        end,
      })
      cmd(
        "MasonUpdateAll", function() updater.update_all() end,
        { desc = "Update Mason Packages" }
      )

      for _, plugin in ipairs {
        "mason-lspconfig",
        "mason-null-ls",
        "mason-nvim-dap",
      } do
        pcall(require, plugin)
      end
    end,
  },

  --  Schema Store [lsp schema manager]
  --  https://github.com/b0o/SchemaStore.nvim
  "b0o/SchemaStore.nvim",

  -- mason-null-ls.nivm
  -- https://github.com/jay-babu/mason-null-ls.nvim
  -- Allows none-ls to use clients installed by mason.
  {
    "jay-babu/mason-null-ls.nvim",
    cmd = {
      "NullLsInstall",
      "NullLsUninstall",
      "NoneLsInstall",
      "NoneLsUninstall"
    },
    opts = { handlers = {} },
  },

  --  none-ls [lsp code formatting]
  --  https://github.com/nvimtools/none-ls.nvim
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "jay-babu/mason-null-ls.nvim",
      "gbprod/none-ls-shellcheck.nvim"
    },
    event = "User BaseFile",
    opts = function()
      local nls = require("null-ls")
      local shellcheck_code_actions = require("none-ls-shellcheck.code_actions")

      -- You can customize your formatters here.
      nls.register(shellcheck_code_actions)  -- shell code actions.
      nls.builtins.formatting.shfmt.with({   -- shell formatter settings.
        command = "shfmt",
        args = { "-i", "2", "-filename", "$FILENAME" },
      })

      -- Attach the user lsp mappings to every none-ls client.
      return {
        on_attach = utils_lsp.apply_user_lsp_mappings,
      }
    end
  },

  --  neodev.nvim [lsp for nvim lua api]
  --  https://github.com/folke/neodev.nvim
  {
    "folke/neodev.nvim",
    opts = {},
    config = function(_, opts)
      require("neodev").setup(opts)
    end,
  },

  --  garbage-day.nvim [lsp garbage collector]
  --  https://github.com/zeioth/garbage-day.nvim
  {
    "zeioth/garbage-day.nvim",
    event = "User BaseFile",
    opts = {
      aggressive_mode = false,
      excluded_lsp_clients = {
        "null-ls", "jdtls"
      },
      grace_period = (60*10),
      wakeup_delay = 3000,
      notifications = false,
      retries = 3,
      timeout = 1000,
    }
  },

  --  AUTO COMPLETION --------------------------------------------------------
  --  Auto completion engine [autocompletion engine]
  --  https://github.com/hrsh7th/nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp"
    },
    event = "InsertEnter",
    opts = function()
      local cmp = require "cmp"
      local snip_status_ok, luasnip = pcall(require, "luasnip")
      local lspkind_status_ok, lspkind = pcall(require, "lspkind")
      if not snip_status_ok then return end
      local border_opts = {
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
      }

      local function has_words_before()
        local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
      end

      return {
        enabled = function()
          local dap_prompt = utils.is_available("cmp-dap") -- add interoperability with cmp-dap
            and vim.tbl_contains(
              { "dap-repl", "dapui_watches", "dapui_hover" },
              vim.api.nvim_get_option_value("filetype", { buf = 0 })
            )
          if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" and not dap_prompt then return false end
          return vim.g.cmp_enabled
        end,
        preselect = cmp.PreselectMode.None,
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = lspkind_status_ok and lspkind.cmp_format(utils.plugin_opts "lspkind.nvim") or nil,
        },
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        duplicates = {
          nvim_lsp = 1,
          luasnip = 1,
          cmp_tabnine = 1,
          buffer = 1,
          path = 1,
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp.config.window.bordered(border_opts),
          documentation = cmp.config.window.bordered(border_opts),
        },
        mapping = {
          ["<PageUp>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
            count = 8,
          },
          ["<PageDown>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Select,
            count = 8,
          },
          ["<C-PageUp>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          },
          ["<C-PageDown>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          },
          ["<S-PageUp>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          },
          ["<S-PageDown>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          },
          ["<Up>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
          },
          ["<Down>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Select,
          },
          ["<C-p>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Insert,
          },
          ["<C-n>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Insert,
          },
          ["<C-k>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Insert,
          },
          ["<C-j>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Insert,
          },
          ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable,
          ["<C-e>"] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          },
          ["<CR>"] = cmp.mapping.confirm { select = false },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources {
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
        },
      }
    end,
  },

}
