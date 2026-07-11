{ ... }:
(
  final: prev:

  let
    inherit (prev) lib stdenv fetchurl;

    version = "0.144.1";
    tag = "rust-v0.144.1";

    cli = {
      aarch64-darwin = {
        target = "aarch64-apple-darwin";
        hash = "sha256-MmGYgp37S2jaWXI89gVHii6b7In/R/62RYFKTF6vX2w=";
      };
      x86_64-darwin = {
        target = "x86_64-apple-darwin";
        hash = "sha256-HHl4gJd1SbKB7rTs2dvRRVQsTOJiooNeooR/GZIu0ww=";
      };
      aarch64-linux = {
        target = "aarch64-unknown-linux-musl";
        hash = "sha256-IYq0i92pjd4+EN8YTMDE65LENy2cqSTvGqX8gbT2o44=";
      };
      x86_64-linux = {
        target = "x86_64-unknown-linux-musl";
        hash = "sha256-P9UM+WgJse6ilLv7oKXDpXaHG0h2ofDpEiblIMGSO+E=";
      };
    };

    system = stdenv.hostPlatform.system;

    cliAsset = cli.${system} or (throw "codex: unsupported system ${system}");

  in
  {
    codex = stdenv.mkDerivation {
      pname = "codex";
      inherit version;

      src = fetchurl {
        url = "https://github.com/openai/codex/releases/download/${tag}/codex-package-${cliAsset.target}.tar.gz";
        hash = cliAsset.hash;
      };

      sourceRoot = ".";
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      dontStrip = true;

      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        for path in bin codex-path codex-resources codex-package.json; do
          if [ -e "$path" ]; then
            cp -R "$path" "$out/"
          fi
        done
        chmod 0755 \
          "$out/bin/codex" \
          "$out/bin/codex-code-mode-host" \
          "$out/codex-path/rg"
        if [ -f "$out/codex-resources/bwrap" ]; then
          chmod 0755 "$out/codex-resources/bwrap"
        fi
        runHook postInstall
      '';

      meta = {
        description = "OpenAI Codex CLI from the official GitHub release bundle";
        homepage = "https://github.com/openai/codex";
        license = lib.licenses.asl20;
        mainProgram = "codex";
        platforms = builtins.attrNames cli;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      };
    };
  }
)
