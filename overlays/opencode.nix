_: final: _prev:

let
  inherit (final) lib stdenv fetchurl;

  version = "2.3.2";

  releaseForSystem = {
    "x86_64-linux" = {
      target = "linux-x64";
      hash = "sha256-hFRo41qlorV0lFoLlmdeZMYE9Sec7ZqnJFBo2MC29rs=";
    };
    "aarch64-linux" = {
      target = "linux-arm64";
      hash = "sha256-kak3Ep79ro64wMUBiuUz+fNRF/Jv/ZpNH3pfnaHmkwY=";
    };
    "x86_64-darwin" = {
      target = "darwin-x64";
      hash = "sha256-VyTmxWAmsCs++2B0fU/3Y+UPEGaXC3i7rrMoGFNqdHk=";
    };
    "aarch64-darwin" = {
      target = "darwin-arm64";
      hash = "sha256-gp+RF5pvQID1KNOmdWuH0umVPev7CgaKWb9HPS11Nak=";
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
