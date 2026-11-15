_: final: _prev:

let
  inherit (final) lib stdenv fetchurl;

  version = "2.3.0";

  releaseForSystem = {
    "x86_64-linux" = {
      target = "linux-x64";
      hash = "sha256-QI+FS1+seFejtN9OeD06i3D1zIx8MYeqwJxb4FdsFK4=";
    };
    "aarch64-linux" = {
      target = "linux-arm64";
      hash = "sha256-vjAGY1O7WSxDkZsxBy/0CZ4GljbDGhaAawiHN+AofOo=";
    };
    "x86_64-darwin" = {
      target = "darwin-x64";
      hash = "sha256-p1dJwNd+8s9LI0tFrRtZpXCv2q4j4NpBbyWHM1V+eV4=";
    };
    "aarch64-darwin" = {
      target = "darwin-arm64";
      hash = "sha256-wlJHpyu50MuP7KZ+uV8UF7YcnPsEKQh1b7r41sFwZB4=";
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
