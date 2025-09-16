{ pkgs, config, ... }:
{
  programs.aichat = {
    enable = true;
    package = pkgs.stdenv.mkDerivation {
      name = "aichat";
      buildInputs = [ pkgs.makeWrapper ];
      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${pkgs.aichat}/bin/aichat $out/bin/aichat --run 'export OPENROUTER_API_KEY=$(cat ${
          config.sops.secrets."openrouter".path
        })'
      '';
    };
    settings = {
      model = "openrouter:openai/gpt-oss-120b";
      clients = [
        {
          type = "openai-compatible";
          name = "openrouter";
          api_base = "https://openrouter.ai/api/v1";
        }
      ];
    };
  };
}
