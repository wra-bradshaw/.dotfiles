_: final: _prev:

let
  inherit (final) lib stdenv fetchurl;

  version = "0.0.0-dev-20040";

  releaseForSystem = {
    "x86_64-linux" = {
      target = "linux-x64";
      hash = "sha512-wJdiVGTZ9AFWLnZ20Wxzg0DAt982Jj1S6cv/vypwNOjQU75cMvP9kxRBd6MgqCqHLeTAoZiJYuwKA0ogTFsSaA==";
    };
    "aarch64-linux" = {
      target = "linux-arm64";
      hash = "sha512-bQMhfZtjWiU7+aa4Vz7jN2IYjivAG9tRfZ2QcltRbJrRgBxVSDtMOyx57oMeKJEPRBKCkGMJ3BNIiaE8jxwa7g==";
    };
    "x86_64-darwin" = {
      target = "darwin-x64";
      hash = "sha512-V4eqpGswRMHnkU1KEu8TdoHCyj0tbb0IUKQbbOeHmuCiZnKJETt2AhIbJ4RK0RKAsUmZ8DskLXhxMoFWDVqhuA==";
    };
    "aarch64-darwin" = {
      target = "darwin-arm64";
      hash = "sha512-0eH3PUXlTqEnPaO6ZBepD2bYmGuZ3rLEm1cXQ03fthsk2QeEpHZ00blNWFrq7jfMKL89TgE8yj1hYt5rJkNCaw==";
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
