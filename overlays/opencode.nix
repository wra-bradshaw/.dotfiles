_: final: _prev:

let
  inherit (final) lib stdenv fetchurl;

  version = "2.2.5";

  releaseForSystem = {
    "x86_64-linux" = {
      target = "linux-x64";
      hash = "sha512-BkHAfTqNsg/qphyHNrnH+DGkOxZsGjamNpM5DvwoEvz7ZAPNw8mEbMXGTCDOAH+/+40Eqeie6KNZBZZQwPCjaA==";
    };
    "aarch64-linux" = {
      target = "linux-arm64";
      hash = "sha512-O4qOy/WRYQmhClMB/5qBaoYfzaDK1+PJRQOfU80ixyj5ruQbCxraH+VW2UyHb6RWOlUv41fec+isd62LvCuwuA==";
    };
    "x86_64-darwin" = {
      target = "darwin-x64";
      hash = "sha512-z+wqIBXk5DVwXVdyQJHOwwnnOlFOx0LfAlx3PzubJjE/3a948KPBkJruF5zm6yyglJGzNgR3ji7oD/B/HOMD+w==";
    };
    "aarch64-darwin" = {
      target = "darwin-arm64";
      hash = "sha512-UwGb2MIJqLSh4wfrkvqNiAohG1Wf5t96Nx7113QvmtCn5LGimmXYN0Tb1chD0mMRRdPvnUguevKRdwM0txZY1Q==";
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
