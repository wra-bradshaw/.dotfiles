{
  pkgs,
  lib,
  ...
}:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "lua"
      "basher"
      "html"
      "dockerfile"
      "sql"
      "php"
    ];

    extraPackages = with pkgs; [
      nixd
      prettierd
      shfmt
      shellcheck
      nixfmt-rfc-style
      pint
      gersemi

      cmake-language-server
      templ
      gopls
      lua-language-server
      bash-language-server
      clang-tools
      astro-language-server
      basedpyright
      tailwindcss-language-server
      yaml-language-server
      vscode-langservers-extracted
      vue-language-server
      typescript-language-server
      terraform-ls
      rust-analyzer
    ];

    userSettings = {
      vim_mode = true;
      vim = {
        enable_vim_sneak = true;
      };

      theme = "Github Theme";

      features = {
        edit_prediction_provider = "zed";
      };
      edit_predictions = {
        mode = "subtle";
      };
      assistant = {
        enabled = false;
        version = "2";
        default_open_ai_model = null;
        default_model = {
          provider = "zed.dev";
          model = "claude-3-5-sonnet-latest";
        };
      };

      ui_font_size = lib.mkForce 12;
      buffer_font_size = lib.mkForce 14;
      relative_line_numbers = true;
      vertical_scroll_margin = 8;
      cursor_line = "all";
      tab_size = 2;

      gutter = {
        line_numbers = true;
      };

      format_on_save = "on";

      file_finder = {
        modal_width = "medium";
      };
      tab_bar = {
        show = true;
      };
      tabs = {
        show_diagnostics = "errors";
      };
      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };
      inlay_hints = {
        enabled = true;
      };
      inactive_opacity = "0.5";
      auto_install_extensions = true;
      outline_panel = {
        dock = "right";
      };
      collaboration_panel = {
        dock = "left";
      };
      notification_panel = {
        dock = "left";
      };
      chat_panel = {
        dock = "left";
      };

      agent_servers = {
        OpenCode = {
          command = "${lib.getExe pkgs.opencode}";
          args = [ "acp" ];
        };
      };

      node = {
        path = lib.getExe pkgs.nodejs_22;
        npm_path = lib.getExe' pkgs.nodejs_22 "npm";
      };

      hour_format = "hour12";
      auto_update = false;

      terminal = {
        alternate_scroll = "off";
        blinking = "off";
        copy_on_select = false;
        dock = "bottom";
        detect_venv = {
          on = {
            directories = [
              ".env"
              "env"
              ".venv"
              "venv"
            ];
            activate_script = "default";
          };
        };
        env = {
          EDITOR = "zed --wait";
          TERM = "ghostty";
        };
        font_family = "FiraCode Nerd Font Mono";
        line_height = "comfortable";
        shell = "system";
        toolbar = {
          title = true;
        };
        working_directory = "current_project_directory";
      };

      file_types = {
        JSON = [
          "json"
          "jsonc"
          "*.code-snippets"
        ];
        Templ = [ "templ" ];
      };

      lsp = {
        rust-analyzer = {
          initialization_options = {
            check = {
              command = "clippy";
            };
          };
        };
        basedpyright = {
          binary = {
            path = "basedpyright-langserver";
            arguments = [ "--stdio" ];
          };
        };
        clangd = {
          binary = {
            path = "clangd";
            arguments = [ "--background-index" ];
          };
        };
        eslint = {
          settings = {
            codeActionOnSave = {
              enable = true;
              mode = "all";
            };
            run = "onType";
            validate = "on";
          };
        };
      };

      languages = {
        JavaScript = {
          formatter = {
            external = {
              command = "prettierd";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        TypeScript = {
          formatter = {
            external = {
              command = "prettierd";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        TSX = {
          formatter = {
            external = {
              command = "prettierd";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        Vue = {
          formatter = {
            external = {
              command = "prettierd";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        Astro = {
          formatter = {
            external = {
              command = "prettierd";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        CSS = {
          formatter = {
            external = {
              command = "prettierd";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        HTML = {
          formatter = {
            external = {
              command = "prettierd";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        JSON = {
          formatter = {
            external = {
              command = "prettierd";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        Markdown = {
          formatter = {
            external = {
              command = "prettierd";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        Nix = {
          formatter = {
            external = {
              command = "nixfmt";
              arguments = [
                "--stdin"
                "{buffer_path}"
              ];
            };
          };
        };
        Shell = {
          formatter = {
            external = {
              command = "shfmt";
              arguments = [
                "-i"
                "2"
                "-ci"
                "-filename"
                "{buffer_path}"
              ];
            };
          };
        };
        PHP = {
          formatter = {
            external = {
              command = "pint";
              arguments = [ "{buffer_path}" ];
            };
          };
        };
        CMake = {
          formatter = {
            external = {
              command = "gersemi";
              arguments = [ "-" ];
            };
          };
        };
        TOML = {
          formatter = "taplo";
        };
        Go = {
          code_actions_on_format = {
            "source.organizeImports" = true;
          };
        };
      };
    };

    userKeymaps = [
      # ---------------------------------------------------------
      # TELESCOPE / NAVIGATION REPLICATION
      # ---------------------------------------------------------
      {
        context = "Editor && vim_mode == normal";
        bindings = {
          # <leader>sf -> Find Files
          "space s f" = "file_finder::Toggle";
          # <leader>gf -> Git Files (Alias to standard finder)
          "space g f" = "file_finder::Toggle";
          # <leader>sg -> Live Grep
          "space s g" = "pane::DeploySearch";

          # <leader><space> -> Buffers (SWITCHER)
          # This triggers the MRU tab switcher explained above
          "space space" = "tab_switcher::Toggle";

          # <leader>? -> Oldfiles
          "space ?" = "projects::OpenRecent";
          # <leader>ds -> Document Symbols
          "space d s" = "outline::Toggle";
        };
      }

      # ---------------------------------------------------------
      # LSP / CODING
      # ---------------------------------------------------------
      {
        context = "Editor && vim_mode == normal";
        bindings = {
          "space r n" = "editor::Rename";
          "space c a" = "editor::ToggleCodeActions";
          "ctrl-f" = "editor::Format";

          "g d" = "editor::GoToDefinition";
          "g D" = "editor::GoToDefinitionSplit";
          "g I" = "editor::GoToImplementation";
          "K" = "editor::Hover";
          "ctrl-k" = "editor::SignatureHelp";

          "[ d" = "editor::GoToPrevDiagnostic";
          "] d" = "editor::GoToDiagnostic";
          "space e" = "editor::Hover";
        };
      }

      # ---------------------------------------------------------
      # EDITING / MOVEMENT
      # ---------------------------------------------------------
      {
        context = "Editor && vim_mode == visual";
        bindings = {
          "J" = "editor::MoveLineDown";
          "K" = "editor::MoveLineUp";
        };
      }
      {
        context = "Editor && vim_mode == insert";
        bindings = {
          "ctrl-l" = "editor::Tab";
          "ctrl-h" = "editor::TabPrev";
          "j j" = "vim::NormalBefore";
          "j k" = "vim::NormalBefore";
        };
      }

      # ---------------------------------------------------------
      # DEFAULT / MISC
      # ---------------------------------------------------------
      {
        context = "Editor && (vim_mode == normal || vim_mode == visual)";
        bindings = {
          "space g h d" = "editor::ToggleHunkDiff";
          "space g h r" = "editor::RevertSelectedHunks";
          "space t i" = "editor::ToggleInlayHints";
          "space u w" = "editor::ToggleSoftWrap";
          "space c z" = "workspace::ToggleCenteredLayout";
          "space m p" = "markdown::OpenPreview";
          "space m P" = "markdown::OpenPreviewToTheSide";
        };
      }
      {
        context = "Editor && vim_mode == normal && !VimWaiting && !menu";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-s" = "workspace::Save";
        };
      }
      {
        context = "ProjectPanel && not_editing";
        bindings = {
          "a" = "project_panel::NewFile";
          "A" = "project_panel::NewDirectory";
          "r" = "project_panel::Rename";
          "d" = "project_panel::Delete";
          "x" = "project_panel::Cut";
          "c" = "project_panel::Copy";
          "p" = "project_panel::Paste";
          "space e" = "workspace::ToggleRightDock";
        };
      }
      {
        context = "Terminal";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-j" = "workspace::ActivatePaneDown";
        };
      }
    ];
  };
}
