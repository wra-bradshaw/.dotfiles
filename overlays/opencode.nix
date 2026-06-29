{ ... }:
(
  final: prev:

  let
    inherit (final) lib stdenv fetchurl;

    version = "1.17.9";

    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    releaseForSystem = {
      "x86_64-linux" = {
        target = "linux-x64";
        ext = "tar.gz";
        hash = lib.fakeHash;
      };

      "aarch64-linux" = {
        target = "linux-arm64";
        ext = "tar.gz";
        hash = lib.fakeHash;
      };

      "x86_64-darwin" = {
        target = "darwin-x64";
        ext = "zip";
        hash = lib.fakeHash;
      };

      "aarch64-darwin" = {
        target = "darwin-arm64";
        ext = "zip";
        hash = "sha256-kT2BOojKT2IJucSOVIvTdu700edMK7ETqpGqlseE0zI=";
      };
    };

    release =
      releaseForSystem.${stdenv.hostPlatform.system}
        or (throw "opencode binary overlay: unsupported system ${stdenv.hostPlatform.system}");

  in
  {
    opencode = stdenv.mkDerivation {
      pname = "opencode";
      inherit version;

      src = fetchurl {
        url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-${release.target}.${release.ext}";
        hash = release.hash;
      };

      dontUnpack = true;
      dontStrip = true;

      nativeBuildInputs = [
        final.makeWrapper
      ]
      ++ lib.optionals (release.ext == "zip") [ final.unzip ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        final.autoPatchelfHook
      ];

      buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
        final.zlib
        final.openssl
        final.icu
        stdenv.cc.cc.lib
      ];

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/bin" unpacked
        cd unpacked

        ${
          if release.ext == "tar.gz" then
            ''
              tar -xzf "$src"
            ''
          else
            ''
              unzip -q "$src"
            ''
        }

        install -m755 opencode "$out/bin/.opencode-unwrapped"
        makeWrapper "$out/bin/.opencode-unwrapped" "$out/bin/opencode"

        runHook postInstall
      '';

      meta = {
        description = "OpenCode - the open source AI coding agent";
        homepage = "https://opencode.ai";
        license = lib.licenses.mit;
        mainProgram = "opencode";
        platforms = supportedSystems;
      };
    };
  }
)
