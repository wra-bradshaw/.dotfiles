{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    tree-sitter
    prettierd
    nodePackages.vscode-langservers-extracted
    nixfmt-rfc-style
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    userCommands = {
      "FormatDisable" = {
        command.__raw = ''
          function(args)
            if args.bang then
              vim.b.disable_autoformat = true
            else
              vim.g.disable_autoformat = true
            end
          end
        '';
        bang = true;
        desc = "Disable autoformat-on-save";
      };
      "FormatEnable" = {
        command.__raw = ''
          function()
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
          end
        '';
        desc = "Re-enable autoformat-on-save";
      };
    };

    autoCmd = [
      {
        event = "BufWritePre";
        callback.__raw = ''
          function()
          	pcall(
          		function()
          			vim.lsp.buf.format({
          				async = false,
          				filter = function(client)
          					return client.name == "eslint"
          				end,
          			})
          		end
          	)
          end
        '';
      }
      {
        event = "FileType";
        pattern = [
          "tex"
          "latex"
          "markdown"
        ];
        command = "setlocal spell";
      }
    ];

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    filetype = {
      extension = {
        templ = "templ";
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>m";
        action.__raw = "function() require'harpoon':list():add() end";
      }
      {
        mode = "n";
        key = "<C-e>";
        action.__raw = "function() require'harpoon'.ui:toggle_quick_menu(require'harpoon':list()) end";
      }
      {
        mode = "n";
        key = "<C-1>";
        action.__raw = "function() require'harpoon':list():select(1) end";
      }
      {
        mode = "n";
        key = "<C-2>";
        action.__raw = "function() require'harpoon':list():select(2) end";
      }
      {
        mode = "n";
        key = "<C-3>";
        action.__raw = "function() require'harpoon':list():select(3) end";
      }
      {
        mode = "n";
        key = "<C-4>";
        action.__raw = "function() require'harpoon':list():select(4) end";
      }
      {
        mode = [ "v" ];
        key = "J";
        action = ":m '>+1<CR>gv=gv";
      }
      {
        mode = [ "v" ];
        key = "K";
        action = ":m '<-2<CR>gv=gv";
      }
      {
        mode = [ "n" ];
        key = "<leader>gg";
        action = ":LazyGit<CR>";
      }
      {
        mode = [
          "i"
          "s"
        ];
        key = "<C-l>";
        action.__raw = ''
          function()
          	local ls = require("luasnip")
          	if ls.jumpable(1) then
          		ls.jump(1)
          	end
          end
        '';
      }
      {
        mode = [
          "i"
          "s"
        ];
        key = "<C-h>";
        action.__raw = ''
          function()
          	local ls = require("luasnip")
          	if ls.jumpable(-1) then
          		ls.jump(-1)
          	end
          end
        '';
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<Space>";
        action = "<Nop>";
        options.silent = true;
      }
      {
        mode = [ "n" ];
        key = "k";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = {
          expr = true;
          silent = true;
        };
      }
      {
        mode = [ "n" ];
        key = "j";
        action = "v:count == 0 ? 'gj' : 'j'";
        options = {
          expr = true;
          silent = true;
        };
      }
    ];

    colorscheme = "github_light";

    colorschemes.github-theme = {
      enable = true;
      settings = {
        options = {
          transparent = true;
        };
        groups = {
          all = {
            BlinkCmpSignatureHelp = {
              bg = "bg1";
            };
            BlinkCmpMenu = {
              bg = "bg1";
            };
          };
          github_light = {
            IblIndent = {
              fg = "#d3d6d9";
            };
            DiagnosticHint = {
              fg = "fg0";
            };
          };
        };
      };
      luaConfig.post = ''
        require('OSC11').setup({
        	on_dark = function()
        		vim.cmd("colorscheme github_dark")
        	end,
        	on_light = function()
        		vim.cmd("colorscheme github_light")
        	end,
        });
      '';
    };

    opts = {
      completeopt = [
        "menu"
        "menuone"
        "noselect"
      ];
      cursorline = true;
      number = true;
      relativenumber = true;
      scrolloff = 8;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      hlsearch = false; # disable search highlighting
      mouse = "a";
      clipboard = "unnamedplus";
      breakindent = true;
      spelllang = "en_gb";
      undofile = true;
      ignorecase = true; # case insensitive searching
      smartcase = true; # unless a capital is used or \C
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      termguicolors = true;
    };

    plugins = {
      which-key = {
        enable = true;
      };
      ts-context-commentstring.enable = true;
      lazygit.enable = true;

      blink-cmp = {
        enable = true;
        settings = {
          completion = {
            accept = {
              auto_brackets = {
                enabled = true;
                semantic_token_resolution = {
                  enabled = false;
                };
              };
            };
            documentation = {
              auto_show = true;
            };
            ghost_text = {
              enabled = true;
            };
          };

          snippets = {
            preset = "luasnip";
          };

          sources = {
            providers = {
              buffer = {
                score_offset = -7;
              };
            };
          };

          signature = {
            enabled = true;
          };

          keymap = {
            preset = "super-tab";
          };

        };

      };

      # cmp = {
      #   enable = true;
      #   autoEnableSources = true;
      #
      #   settings = {
      #     snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
      #
      #     mapping = {
      #       "<C-n>" = "cmp.mapping.select_next_item()";
      #       "<C-p>" = "cmp.mapping.select_prev_item()";
      #       "<CR>" = ''
      #         cmp.mapping.confirm {
      #         	      behavior = cmp.ConfirmBehavior.Replace,
      #         	      select = true,
      #         	    }'';
      #       "<Tab>" =
      #         "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end, { 'i', 's' })";
      #       "<S-Tab>" =
      #         "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() else fallback() end end, { 'i', 's' })";
      #     };
      #     sources = [
      #       { name = "luasnip"; }
      #       { name = "nvim_lsp"; }
      #       { name = "path"; }
      #       { name = "nvim_lsp_signature_help"; }
      #       {
      #         name = "buffer";
      #         option.get_bufnrs.__raw = "vim.api.nvim_list_bufs"; # Words from other buffers are suggested
      #       }
      #     ];
      #   };
      # };
      # cmp-nvim-lsp.enable = true;
      # cmp-nvim-lsp-signature-help.enable = true;

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end
              return { timeout_ms = 500 }
            end
          '';
          notify_on_error = true;
          formatters_by_ft = {
            bash = [
              "shellcheck"
              "shellharden"
              "shfmt"
            ];
            c = [
              "clang-format"
            ];
            cpp = [
              "clang-format"
            ];
            javascript = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            javascriptreact = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            typescript = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            typescriptreact = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            html = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            vue = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            astro = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            svelte = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            css = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            scss = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            json = {
              __unkeyed-1 = "prettierd";
              timeout_ms = 5000;
            };
            nix = {
              __unkeyed-1 = "nixfmt";
              timeout_ms = 5000;
            };
            php = {
              __unkeyed-1 = "pint";
              timeout_ms = 5000;
            };
            markdown = {
              "lsp_format" = "fallback";
            };
            yaml = {
              "lsp_format" = "fallback";
            };
            go = {
              "lsp_format" = "fallback";
            };
            terraform = {
              "lsp_format" = "fallback";
            };
            "_" = [
              "squeeze_blanks"
              "trim_whitespace"
              "trim_newlines"
            ];
          };
          formatters = {
            shellcheck = {
              command = pkgs.lib.getExe pkgs.shellcheck;
            };
            shfmt = {
              command = pkgs.lib.getExe pkgs.shfmt;
            };
            shellharden = {
              command = pkgs.lib.getExe pkgs.shellharden;
            };
            squeeze_blanks = {
              command = pkgs.lib.getExe' pkgs.coreutils "cat";
            };
          };
        };
      };

      luasnip = {
        enable = true;
      };
      fugitive = {
        enable = true;
      };
      lualine = {
        enable = true;
        settings = {
          sections = {
            lualine_c = [
              {
                __unkeyed-1 = "filename";
                path = 1;
              }
            ];
          };

          options = {
            component_separators = {
              left = "|";
              right = "|";
            };
            section_separators = {
              left = "";
              right = "";
            };
          };
        };
      };
      indent-blankline = {
        enable = true;
      };
      comment = {
        enable = true;
      };

      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add = {
              text = "+";
            };
            change = {
              text = "~";
            };
            delete = {
              text = "_";
            };
            topdelete = {
              text = "‾";
            };
            changedelete = {
              text = "~";
            };
          };
        };
      };
      harpoon = {
        enable = true;
        enableTelescope = true;
      };
      treesitter = {
        enable = true;
        nixvimInjections = true;

        settings = {
          indent.enable = true;
          incremental_selection = {
            enable = true;
            keymaps = {
              node_incremental = "v";
              node_decremental = "V";
            };
          };
        };
      };
      treesitter-textobjects.enable = true;
      lsp = {
        enable = true;
        servers = {
          templ.enable = true;
          gopls.enable = true;
          lua_ls.enable = true;
          bashls.enable = true;
          clangd.enable = true;
          nixd.enable = true;
          astro.enable = true;
          sourcekit.enable = true;
          basedpyright.enable = true;
          tailwindcss.enable = true;
          yamlls.enable = true;

          intelephense = {
            enable = true;
            package = pkgs.intelephense;
            rootMarkers = [
              "composer.lock"
              ".git"
            ];
          };

          html.enable = true;
          jsonls.enable = true;
          cssls.enable = true;
          eslint.enable = true;
          volar.enable = true;

          ts_ls = {
            enable = true;
            rootMarkers = [
              "package.json"
            ];
            filetypes = [
              "javascript"
              "javascriptreact"
              "javascript.jsx"
              "typescript"
              "typescriptreact"
              "typescript.tsx"
              "astro"
            ];
            extraOptions = {
              single_file_support = false;
            };
          };
          # denols = {
          #   enable = true;
          #   rootMarkers = [
          #     "deno.json"
          #     "deno.jsonc"
          #   ];
          # };
          terraformls.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
        keymaps = {
          lspBuf = {
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
            "gd" = "definition";
            "gI" = "implementation";
            "<leader>D" = "type_definition";
            "K" = "hover";
            "<C-k>" = "signature_help";
            "gD" = "declaration";
            "<leader>wa" = "add_workspace_folder";
            "<leader>wr" = "remove_workspace_folder";
            "<leader>wl" = "list_workspace_folders";
            "<C-f>" = "format";
          };
          diagnostic = {
            "[d" = "goto_prev";
            "]d" = "goto_next";
            "<leader>e" = "open_float";
            "<leader>q" = "setloclist";
          };
        };
      };
      fidget = {
        enable = true;
      };
      nvim-autopairs = {
        enable = true;
      };
      mini = {
        enable = true;
        modules.icons.enable = true;
        mockDevIcons = true;
      };
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        keymaps = {
          "<leader>?" = "oldfiles";
          "<leader><Space>" = "buffers";
          "<leader>gr" = "lsp_references";
          "<leader>ds" = "lsp_document_symbols";
          "<leader>ws" = "lsp_dynamic_workspace_symbols";
          "<leader>gf" = "git_files";
          "<leader>sf" = "find_files";
          "<leader>sh" = "help_tags";
          "<leader>sw" = "grep_string";
          "<leader>sg" = "live_grep";
          "<leader>sd" = "diagnostics";
          "<leader>sr" = "resume";
          "<leader>st" = "treesitter";
        };
      };
    };
    extraPlugins = [
      pkgs.vimPlugins.vim-rhubarb
      pkgs.vimPlugins.plenary-nvim
      (pkgs.vimUtils.buildVimPlugin {
        name = "osc11";
        src = pkgs.fetchFromGitHub {
          owner = "afonsofrancof";
          repo = "OSC11.nvim";
          rev = "main";
          hash = "sha256-s7HyMf90WdO0pyk1EQeRzOwK+5jbPDaoooK/sKroCw4=";
        };
      })
    ];
  };
}
