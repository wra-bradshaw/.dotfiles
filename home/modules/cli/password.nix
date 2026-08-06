{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "pwgen" ''
      aspell dump master | shuf -n3 | tr "\n" " "
    '')
  ];
}
