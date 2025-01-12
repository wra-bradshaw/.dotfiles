{ pkgs, ... }:
{
  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;
  home.packages = [
    (pkgs.writeShellScriptBin "mkPrj" ''
      mkdir "$1"
      pushd "$1"
      echo -e "{\n\tdescription = \"\";\n\n\tinputs = {\n\t\tnixpkgs.url = \"github:NixOS/nixpkgs\";\n\t\tflake-utils.url = \"github:numtide/flake-utils\";\n\t};\n\n\toutputs = { self, nixpkgs, flake-utils, }:\n\t\tflake-utils.lib.eachDefaultSystem (system: \n\t\t\tlet \n\t\t\t\toverlays = [];\n\t\t\t\tlib = nixpkgs.lib;\n\t\t\t\tpkgs = import nixpkgs { inherit system overlays; };\n\t\t\tin\n\t\t\t\t{\n\t\t\t\t\tpackages = {\n\t\t\t\t\t};\n\t\t\t\t\t# defaultPackage = example;\n\t\t\t\t\tdevShell = pkgs.mkShell {\n\t\t\t\t\t\tpackages = with pkgs; [ ];\n\t\t\t\t\t\tshellHook = '''\n\t\t\t\t\t\t''';\n\t\t\t\t\t};\n\t\t\t\t}\n\t\t);\n}" > flake.nix
      echo -e ".direnv\nresult" > .gitignore
      git init
      git add -A
      nix develop --command exit
      echo "use flake ." > .envrc
      direnv allow
      popd
    '')
  ];

}
