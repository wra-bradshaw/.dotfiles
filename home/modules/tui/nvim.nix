{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    tree-sitter
    nodePackages.vscode-langservers-extracted
  ];

  home.sessionVariables = { EDITOR = "nvim"; };

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    autoCmd = [
      {
        event = "BufWritePre";
        callback = {
          __raw = "function() vim.lsp.buf.format { async = false } end";
        };
      }
      {
        event = "FileType";
        pattern = [ "tex" "latex" "markdown" ];
        command = "setlocal spell";
      }
    ];

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    filetype = { extension = { templ = "templ"; }; };

    keymaps = [
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
        mode = [ "n" "v" ];
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

    colorschemes.tokyonight = {
      enable = true;
      settings = { style = "storm"; };
    };

    opts = {
      completeopt = [ "menu" "menuone" "noselect" ];
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
      which-key = { enable = true; };
      none-ls = {
        enable = true;
        sources = {
          formatting = {
            prettierd.enable = true;
            nixfmt = {
              enable = true;
              package = pkgs.nixfmt-rfc-style;
            };
          };
        };
      };
      cmp = {
        enable = true;
        autoEnableSources = true;

        settings = {
          snippet.expand =
            "function(args) require('luasnip').lsp_expand(args.body) end";

          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-Space>" = "cmp.mapping.complete {}";
            "<CR>" = ''
              cmp.mapping.confirm {
              	      behavior = cmp.ConfirmBehavior.Replace,
              	      select = true,
              	    }'';
            "<Tab>" =
              "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end, { 'i', 's' })";
            "<S-Tab>" =
              "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() else fallback() end end, { 'i', 's' })";
          };
          sources = [
            { name = "luasnip"; }
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "supermaven"; }
            {
              name = "buffer";
              option.get_bufnrs.__raw =
                "vim.api.nvim_list_bufs"; # Words from other buffers are suggested
            }
          ];

          completion.autocomplete = [ "TextChanged" ];
        };
      };
      cmp-nvim-lsp.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;

      luasnip = { enable = true; };
      fugitive = { enable = true; };
      lualine = {
        enable = true;
        componentSeparators = {
          left = "|";
          right = "|";
        };
        sectionSeparators = {
          left = "";
          right = "";
        };
      };
      indent-blankline = { enable = true; };
      comment = { enable = true; };

      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add = { text = "+"; };
            change = { text = "~"; };
            delete = { text = "_"; };
            topdelete = { text = "‾"; };
            changedelete = { text = "~"; };
          };
        };
      };
      harpoon = {
        enable = true;
        enableTelescope = true;
        keymaps = {
          addFile = "m";
          navFile = {
            "1" = "<C-1>";
            "2" = "<C-2>";
            "3" = "<C-3>";
            "4" = "<C-4>";
          };
          toggleQuickMenu = "<C-e>";
        };
      };
      treesitter = {
        enable = true;
        nixvimInjections = true;

        settings = { indent.enable = true; };
      };
      treesitter-textobjects.enable = true;
      lsp = {
        enable = true;
        servers = {
          templ.enable = true;
          gopls.enable = true;
          lua-ls.enable = true;
          nixd.enable = true;
          
          intelephense = {
            enable = true;
            rootDir = ''function(fname)
              local util = require 'lspconfig.util'
              local path = util.search_ancestors(fname, function(path)
                if util.path.is_file(util.path.join(path, 'composer.lock')) then
                  return path
                end
              end)

              if path ~= nil then
                return path
              else
                return util.find_git_ancestor(fname)
              end
            end
            '';
          }; 

          html.enable = true;
          jsonls.enable = true;
          cssls.enable = true;

          tsserver.enable = true;
          terraformls.enable = true;
          rust-analyzer = {
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
      fidget = { enable = true; };
      nvim-autopairs = { enable = true; };
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
          "<leader>st" = "treesitter";
        };
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      neodev-nvim
      vim-rhubarb
      vim-sleuth
      plenary-nvim
      supermaven-nvim
    ];
    extraConfigLua = ''
      require('supermaven-nvim').setup({})
    '';
  };
}
