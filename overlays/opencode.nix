_: final: _prev:

let
  inherit (final) lib stdenv fetchurl;

  version = "2.2.6";

  releaseForSystem = {
    "x86_64-linux" = {
      target = "linux-x64";
      hash = "sha256-381p8dURrhDtYmdotB2EuBAMxKpkzstp2ji6einTNVE=";
    };
    "aarch64-linux" = {
      target = "linux-arm64";
      hash = "sha256-IjUuIAYw7GGkimW59cK2JzKK5QAmWNgcBn9nxftomJg=";
    };
    "x86_64-darwin" = {
      target = "darwin-x64";
      hash = "sha256-TxR1wLZC7OMmgdvUov1ffB72GD3O0OysOGHLPRikmhU=";
    };
    "aarch64-darwin" = {
      target = "darwin-arm64";
      hash = "sha256-YT67dN2O/3Z7udRCo3tAxNmUa6J/FTiYUGihuWeBN6M=";
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
