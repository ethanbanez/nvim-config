-- since this is just an example spec, don't actually load anything here and return an empty spec

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {

    {
        "sainnhe/sonokai",
    },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "sonokai",
        },
    },

    {
        "stevearc/conform.nvim",
    },

    {
        "nvim-telescope/telescope.nvim",
        opts = function()
            return {
                pickers = {
                    find_files = {
                        hidden = true,
                    },
                },
            }
        end,
    },

    -- change trouble config
    {
        "folke/trouble.nvim",
        -- opts will be merged with the parent spec
        opts = { use_diagnostic_signs = true },
    },

    -- add pyright to lspconfig
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = function() end,
    },

    -- add tsserver and setup with typescript.nvim instead of lspconfig
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },
        init = function()
            local lspconfig = require("lspconfig")
            local utils = lspconfig.util

            local oldpath = package.path
            local clangd_compiler_path = ";"
                .. os.getenv("HOME")
                .. "/.config/nvim/lua/plugins/clangd/cross-compiler.lua;"
            package.path = package.path .. clangd_compiler_path

            local cross_compiler_path = require("clangd.cross-compiler")
            package.path = oldpath

            lspconfig.mesonlsp.setup({})
            lspconfig.clangd.setup({
                cmd = {
                    "clangd",
                    "--background-index",
                    "--query-driver=" .. cross_compiler_path,
                    "--clang-tidy",
                    "--log=verbose",
                    "--pretty",
                },
                filetypes = { "c" },
                root_dir = function(fname)
                    return utils.root_pattern(
                        ".clangd",
                        ".clang-tidy",
                        ".clang-format",
                        "compile_commands.json",
                        "build/compile_commands.json",
                        "compile_flags.txt",
                        "configure.ac"
                    )(fname) or vim.fs.dirname(
                        vim.fs.find(".git", { path = fname, upward = true })[1]
                    )
                end,
            })
        end,
        config = function(_, opts)
            local lspconfig = require("lspconfig")
            for server, config in pairs(opts.servers) do
                -- passing config.capabilities to blink.cmp merges with the capabilities in your
                -- `opts[server].capabilities, if you've defined it
                config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
                lspconfig[server].setup(config)
            end
        end,
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            filesystem = {
                filtered_items = {
                    hide_gitignored = false,
                },
                follow_current_file = {
                    enabled = true,
                    leave_dirs_open = false,
                },
            },
        },
    },

    -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
    -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
    -- { import = "lazyvim.plugins.extras.lang.typescript" },

    -- add more treesitter parsers
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "c",
                "bash",
                "lua",
                "vim",
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
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        opts = {},
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },

    {
        "saghen/blink.cmp",
        enabled = true,
        build = "cargo build",
        opts = {
            keymap = {
                preset = "super-tab",
                ["<C-;"] = { "show", "show_documentation", "hide_documentation" },
            },
        },
    },

    {
        "hrsh7th/nvim-cmp",
        enabled = false,
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        init = function()
            local harpoon = require("harpoon")
            local keymaps = vim.keymap
            harpoon:setup()

            keymaps.set("n", "<leader>a", function()
                harpoon:list():add()
            end)

            keymaps.set("n", "<CR>", function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end)

            keymaps.set("n", "<C-n>", function()
                harpoon:list():prev()
            end)

            keymaps.set("n", "<C-m>", function()
                harpoon:list():next()
            end)
        end,
        keys = {},
    },

    {
        "rasulomaroff/cursor.nvim",
        event = "VeryLazy",
        opts = {
            -- Your options go here
            overwrite_cursor = true,
            cursors = {
                {
                    mode = "n-v-c",
                    blink = { wait = 75, default = 400 },
                    shape = "block",
                },
                {
                    mode = "i",
                    blink = { wait = 75, default = 400 },
                    shape = "hor",
                    size = 40,
                },
            },
        },
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
                "lua-language-server",
                "clangd",
                "shellcheck",
                "shfmt",
            },
        },
    },
}
