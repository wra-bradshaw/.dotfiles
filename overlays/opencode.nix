_: final: _prev:

let
  inherit (final) lib stdenv fetchurl;

  # OpenCode v2 is currently published under the `beta` npm dist-tag.
  version = "0.0.0-beta-202608072055";

  releaseForSystem = {
    "x86_64-linux" = {
      target = "linux-x64";
      hash = "sha512-hgvV06p8x51KTOI9mqT05J0CiuYBcirW+XYcdNeX9beFwjrriGKUY6tOrkD1wQgvwEkLhlIX9gkL33NSSnwEJQ==";
    };
    "aarch64-linux" = {
      target = "linux-arm64";
      hash = "sha512-9D+m7js5DxzGdQyuxejp1XG6IoqW7K5bcY8VoqeHPaNOO0mTvs9iI2pXnHg1Kxwi4ali9BGXy2NaT/Vi9QYteA==";
    };
    "x86_64-darwin" = {
      target = "darwin-x64";
      hash = "sha512-z446F7Sq2pw1IGKnTBxZeQmrXuyuUh/YwOTEcjawqVWqOg3xKUGyiqgg4SCssUz+d3TgPCWOZXU3UtyNyfuoAA==";
    };
    "aarch64-darwin" = {
      target = "darwin-arm64";
      hash = "sha512-I23QO4Jl12JgMVD5SQGGPKMTJOv7QsCrYhg60ro8I9jl5c+CFpAkUel7+B4vEH59rq+DObPh23ClfkGQuqoogw==";
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
      url = "https://registry.npmjs.org/opencode-${release.target}/-/opencode-${release.target}-${version}.tgz";
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
