-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
    {
        "LazyVim/LazyVim",
        opts = {
            -- colorscheme = "gruvbox",
        },
    },

    -- change trouble config
    {
        "folke/trouble.nvim",
        -- opts will be merged with the parent spec
        opts = { use_diagnostic_signs = true },
    },

    -- disable trouble
    { "folke/trouble.nvim", enabled = true },

    -- add pyright to lspconfig
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = function()
        end,
    },

    -- add tsserver and setup with typescript.nvim instead of lspconfig
    {
        "neovim/nvim-lspconfig",
    },

    -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
    -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
    -- { import = "lazyvim.plugins.extras.lang.typescript" },

    -- add more treesitter parsers
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "rust",
                "c",
                "cpp",
                "zig",
                "toml",
                "bash",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "vim",
                "yaml",
            },
        },
    },

    -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
    -- would overwrite `ensure_installed` with the new value.
    -- If you'd rather extend the default config, use the code below instead:
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- add tsx and treesitter
            vim.list_extend(opts.ensure_installed, {
                --"tsx",
                --"typescript",
            })
        end,
    },

    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true,
        opts = {}
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },

    {
      "echasnovski/mini.pairs",
      event = "VeryLazy",
      opts = {
        modes = { insert = true, command = true, terminal = false },
        -- skip autopair when next character is one of these
          skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
          -- skip autopair when the cursor is inside these treesitter nodes
          skip_ts = { "string" },
          -- skip autopair when next character is closing pair
          -- and there are more closing pairs than opening pairs
          skip_unbalanced = true,
          -- better deal with markdown code blocks
          markdown = true,
        },
      config = function(_, opts)
        LazyVim.mini.pairs(opts)
      end,
    },

    {
        "hrsh7th/nvim-cmp",
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)

            local cmp = require("cmp")

            opts.mapping = vim.tbl_extend("force", opts.mapping, {
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
                        cmp.confirm({select = true})
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<C-Space>"] = cmp.mapping(function()
                      cmp.complete()
                end, { "i", "s" })
            })
            
            cmp.setup {
                formatting = {
                    fields = { "kind", "abbr" },
                    format = function(_, vim_item)
                        vim_item.kind = cmp_kinds[vim_item.kind] or ""
                        return vim_item
                    end,
                }
            }
      
            opts.auto_brackets = {"rust", "c", "cpp", "zig"}
        end,
    },

    -- the opts function can also be used to change the default opts:
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = function(_, opts)
            table.insert(opts.sections.lualine_x, {
                function()
                    -- return "😄"
                end,
            })
        end,
    },

    -- or you can return new options to override all the defaults
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = function()
            return {
                --[[add your custom lualine config here]]
            }
        end,
    },

    -- use mini.starter instead of alpha
    -- { import = "lazyvim.plugins.extras.ui.mini-starter" },

    -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
    -- { import = "lazyvim.plugins.extras.lang.json" },

    -- add any tools you want to have installed below
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",
                "shellcheck",
                "shfmt",
            },
        },
    },
}