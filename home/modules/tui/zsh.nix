{ pkgs, config, ... }:
{
  home.packages = [ pkgs.ollama ];
  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;
    defaultKeymap = "viins";
    sessionVariables = {
      DIRENV_LOG_FORMAT = null;
    };

    shellAliases = {
      calc = "kalker";
      view = "swayimg";
      download = "aria2c";
      copy = "wl-copy";
      paste = "wl-paste";
    };

    oh-my-zsh.enable = true;

    plugins = [
      {
        name = "autopair";
        file = "share/zsh/zsh-autopair/autopair.zsh";
        src = pkgs.zsh-autopair;
      }
      {
        name = "fast-syntax-highlighting";
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
    ];

    initContent = ''
      PROMPT='%{$fg_bold[blue]%}$(get_pwd)%{$reset_color%} ''${prompt_suffix}'
      local prompt_suffix="%(?:%{$fg_bold[green]%}❯ :%{$fg_bold[red]%}❯%{$reset_color%} "
      RPROMPT=

      function get_pwd(){
          git_root=$PWD
          while [[ $git_root != / && ! -e $git_root/.git ]]; do
              git_root=$git_root:h
          done
          if [[ $git_root = / ]]; then
              unset git_root
              prompt_short_dir=%~
          else
              parent=''${git_root%\/*}
              prompt_short_dir=''${PWD#$parent/}
          fi
          echo $prompt_short_dir
      }

      vterm_printf(){
          if [ -n "$TMUX" ]; then
              # Tell tmux to pass the escape sequences through
              # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
              printf "\ePtmux;\e\e]%s\007\e\\" "$1"
          elif [ "''${TERM%%-*}" = "screen" ]; then
              # GNU screen (screen, screen-256color, screen-256color-bce)
              printf "\eP\e]%s\007\e\\" "$1"
          else
              printf "\e]%s\e\\" "$1"
          fi
      }

      eval "$(fnm env --use-on-cd --shell zsh)"
    '';
  };
}
