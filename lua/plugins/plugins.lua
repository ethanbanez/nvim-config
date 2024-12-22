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
        opts = {
            formatters_by_ft = {
                c = { "clang_format", lsp_format = "prefer" },
                cpp = { "clang_format", lsp_format = "prefer" },
            },
        },
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
                    "--use-dirty-headers",
                    "--compile_args_from=filesystem",
                    "--all-scopes-completion",
                },
                filetypes = { "c" },
                root_dir = function(fname)
                    return utils.root_pattern(
                        ".clangd",
                        ".clang-tidy",
                        ".clang-format",
                        "compile_commands.json",
                        "compile_flags.txt",
                        "configure.ac"
                    )(fname) or vim.fs.dirname(
                        vim.fs.find(".git", { path = fname, upward = true })[1]
                    )
                end,
            })
        end,
        config = function(_, opts)
            LazyVim.lsp.on_attach(function(client, buffer)
                require("lazyvim.plugins.lsp.keymaps").get()
                require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
            end)

            LazyVim.lsp.setup()
            LazyVim.lsp.on_dynamic_capability(require("lazyvim.plugins.lsp.keymaps").on_attach)

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
                "asm",
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
        dir = "/home/biggestskittle/programming/blink.cmp",
        name = "blink.cmp",
        enabled = true,
        build = "cargo build --release",
        opts = {
            keymap = {
                preset = "super-tab",
                ["<C-Space>"] = { "show", "hide", "show_documentation", "hide_documentation" },
            },
        },
    },

    --{
    --"saghen/blink.cmp",
    --version = "",
    --enabled = true,
    --build = "cargo build",
    --opts = {
    --keymap = {
    --preset = "super-tab",
    --["<C-Space>"] = { "show", "hide", "show_documentation", "hide_documentation" },
    --},
    --},
    --},

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

    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            -- virtual text for the debugger
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {},
            },
        },

        keys = {
            {
                "<leader>dB",
                function()
                    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
                end,
                desc = "Breakpoint Condition",
            },
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Toggle Breakpoint",
            },
            {
                "<leader>dc",
                function()
                    require("dap").continue()
                end,
                desc = "Run/Continue",
            },
            {
                "<leader>da",
                function()
                    require("dap").continue({ before = get_args })
                end,
                desc = "Run with Args",
            },
            {
                "<leader>dC",
                function()
                    require("dap").run_to_cursor()
                end,
                desc = "Run to Cursor",
            },
            {
                "<leader>dg",
                function()
                    require("dap").goto_()
                end,
                desc = "Go to Line (No Execute)",
            },
            {
                "<leader>di",
                function()
                    require("dap").step_into()
                end,
                desc = "Step Into",
            },
            {
                "<leader>dj",
                function()
                    require("dap").down()
                end,
                desc = "Down",
            },
            {
                "<leader>dk",
                function()
                    require("dap").up()
                end,
                desc = "Up",
            },
            {
                "<leader>dl",
                function()
                    require("dap").run_last()
                end,
                desc = "Run Last",
            },
            {
                "<leader>do",
                function()
                    require("dap").step_out()
                end,
                desc = "Step Out",
            },
            {
                "<leader>dO",
                function()
                    require("dap").step_over()
                end,
                desc = "Step Over",
            },
            {
                "<leader>dP",
                function()
                    require("dap").pause()
                end,
                desc = "Pause",
            },
            {
                "<leader>dr",
                function()
                    require("dap").repl.toggle()
                end,
                desc = "Toggle REPL",
            },
            {
                "<leader>ds",
                function()
                    require("dap").session()
                end,
                desc = "Session",
            },
            {
                "<leader>dt",
                function()
                    require("dap").terminate()
                end,
                desc = "Terminate",
            },
            {
                "<leader>dw",
                function()
                    require("dap.ui.widgets").hover()
                end,
                desc = "Widgets",
            },
        },

        config = function()
            if LazyVim.has("mason-nvim-dap.nvim") then
                require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
            end

            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

            for name, sign in pairs(LazyVim.config.icons.dap) do
                sign = type(sign) == "table" and sign or { sign }
                vim.fn.sign_define(
                    "Dap" .. name,
                    { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
                )
            end

            local dap = require("dap")
            --dap.adapters.gdb = {
            --type = "executable",
            --command = "gdb",
            --args = {}, -- set the target? what else??
            --}

            --dap.adapters["cortex-debug"] = {
            --type = "executable",
            ----command = "gdb",
            --command = "/home/biggestskittle/embedded-toolchains/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gdb",
            --args = { "--eval-command", "set print pretty on" }, -- set the target? what else??
            --}
            --
            local root_dir
            LazyVim.lsp.on_attach(function(client, buffer)
                if client.name ~= "clangd" then
                    return
                end

                root_dir = vim.fs.root(0, "compile_commands.json")

                local exec_find = function()
                    return vim.fn.input("Path to executable: ", root_dir .. "/", "file")
                end

                local exec = exec_find()

                dap.configurations.c = {
                    {
                        name = "debugging with OpenOCD",
                        type = "cortex-debug",
                        request = "launch",
                        servertype = "openocd",
                        serverpath = "openocd",
                        gdbPath = "arm-none-eabi-gdb",
                        toolchainPath = "/home/biggestskittle/embedded-toolchains/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin/",
                        toolchainPrefix = "arm-none-eabi",
                        runToEntryPoint = "Reset_Handler",
                        swoConfig = { enabled = false },
                        showDevDebugOutput = true,
                        gdbTarget = "localhost:3333",
                        cwd = root_dir,
                        executable = exec,
                        configFiles = { root_dir .. "/openocd/debug.cfg" },
                        rttConfig = {
                            address = "auto",
                            decoders = {
                                {
                                    label = "RTT:0",
                                    port = 0,
                                    type = "console",
                                },
                            },
                            enabled = false,
                        },
                    },
                }
            end)
        end,
        opts = {},
    },
    {
        "jedrzejboczar/nvim-dap-cortex-debug",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            local dap_cortex_debug = require("dap-cortex-debug")
            LazyVim.lsp.on_attach(function(client, buffer)
                if client.name == "clangd" then
                    dap_cortex_debug.setup({
                        debug = false,
                        extension_path = "/home/biggestskittle/Downloads/cortex-debug/",
                        lib_extension = "",
                        node_path = "node",
                        dap_vscode_filetypes = { "c" },
                    })
                end
            end)
        end,
    },
}
