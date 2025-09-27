{ pkgs, config, ... }:
{
  home.packages = [
    (pkgs.stdenv.mkDerivation {
      name = "codex";
      buildInputs = [ pkgs.makeWrapper ];
      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${pkgs.codex}/bin/codex $out/bin/codex --run 'export OPENAI_API_KEY=$(cat ${
          config.sops.secrets."openai".path
        })'
      '';
    })
  ];
}
