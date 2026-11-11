_: final: _prev:

let
  inherit (final) lib stdenv fetchurl;

  version = "2.2.7";

  releaseForSystem = {
    "x86_64-linux" = {
      target = "linux-x64";
      hash = "sha256-1lk1Rk+T8HkTYz+XfLmXI69k7v9q56gicizom+2r3UU=";
    };
    "aarch64-linux" = {
      target = "linux-arm64";
      hash = "sha256-fnTOtk/lcE/y/e897kWGbvy1gNcfGCpsrilgbK0fi1I=";
    };
    "x86_64-darwin" = {
      target = "darwin-x64";
      hash = "sha256-ovG9AsNuGA1DmZpwEmISUR72doY0XWAHJN2T6nTedgE=";
    };
    "aarch64-darwin" = {
      target = "darwin-arm64";
      hash = "sha256-jU+QxbI/qnJLoch32DWAcru2VlwzuNi13KfHZExN4L8=";
    };
  };

  release =
    releaseForSystem.${stdenv.hostPlatform.system}
      or (throw "opencode v2 overlay: unsupported system ${stdenv.hostPlatform.system}");
in
{
  opencode = stdenv.mkDerivation {
    pname = "opencode";
    inherit version;

    src = fetchurl {
      url = "https://registry.npmjs.org/@opencode/cli-${release.target}/-/cli-${release.target}-${version}.tgz";
      inherit (release) hash;
    };

    dontStrip = true;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ final.autoPatchelfHook ];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
      final.zlib
      final.openssl
      final.icu
      stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 bin/opencode "$out/bin/opencode"
      runHook postInstall
    '';

    meta = {
      description = "OpenCode v2 beta - the open source AI coding agent";
      homepage = "https://opencode.ai";
      license = lib.licenses.mit;
      mainProgram = "opencode";
      platforms = builtins.attrNames releaseForSystem;
    };
  };
}
