{ ... }:
(
  final: prev:

  let
    inherit (final) lib stdenv fetchurl;

    # OpenCode v2 is currently published under the `next` npm dist-tag.
    version = "0.0.0-next-16893";

    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    releaseForSystem = {
      "x86_64-linux" = {
        target = "linux-x64";
        hash = "sha256-7aIyijwufTmDmyxPv4vrIRJ7Og1I+Ic3F8L1PDcc/34=";
      };

      "aarch64-linux" = {
        target = "linux-arm64";
        hash = "sha256-eUpnMvevGzNAcne12xlKpVl+HaXeI7obSuFjVOb0GTM=";
      };

      "x86_64-darwin" = {
        target = "darwin-x64";
        hash = "sha256-lL33tD3DU6l7EG5m0hE8g1bO0DcQMvh2bkyjVmBNpXQ=";
      };

      "aarch64-darwin" = {
        target = "darwin-arm64";
        hash = "sha256-Xb7RRrj82ojc9JPG+sbBWY0eDDs/u54z6Ewy8W3KfcM=";
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
        url = "https://registry.npmjs.org/@opencode-ai/cli-${release.target}/-/cli-${release.target}-${version}.tgz";
        hash = release.hash;
      };

      dontStrip = true;

      nativeBuildInputs = [
        final.makeWrapper
      ]
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

        mkdir -p "$out/bin"
        install -m755 bin/opencode2 "$out/bin/.opencode-unwrapped"
        makeWrapper "$out/bin/.opencode-unwrapped" "$out/bin/opencode"
        makeWrapper "$out/bin/.opencode-unwrapped" "$out/bin/opencode2"

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
