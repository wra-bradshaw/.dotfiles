{ pkgs, config, ... }:
{
  home.packages =
    let
      codex = pkgs.codex.overrideAttrs (
        finalAttrs: previousAttrs: {
          version = "0.20.0";
          src = pkgs.fetchFromGitHub {
            owner = "openai";
            repo = "codex";
            tag = "rust-v${finalAttrs.version}";
            hash = "sha256-v5PEj3T/eirAMpHHMR6LE9X8qDNhvCJP40Nleal3oOw=";
          };

          cargoDeps = previousAttrs.cargoDeps.overrideAttrs (previousAttrs: {
            vendorStaging = previousAttrs.vendorStaging.overrideAttrs {
              inherit (finalAttrs) src;
              outputHash = "sha256-zgmiWyWB08v1WQVFzxpC/LGwF+XXbs8iW1d7i9Iw0Q4=";
            };
          });

          doCheck = false;
        }
      );
    in
    [
      (pkgs.stdenv.mkDerivation {
        name = "codex";
        buildInputs = [ pkgs.makeWrapper ];
        dontUnpack = true;

        installPhase = ''
          mkdir -p $out/bin
          makeWrapper ${codex}/bin/codex $out/bin/codex --run 'export OPENAI_API_KEY=$(cat ${
            config.sops.secrets."openai".path
          })'
        '';
      })
    ];
}
