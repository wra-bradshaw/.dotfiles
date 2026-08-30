_: final: _prev:

let
  inherit (final) lib stdenv fetchurl;

  # OpenCode v2 is currently published under the `beta` npm dist-tag.
  version = "0.0.0-beta-202608110357";

  releaseForSystem = {
    "x86_64-linux" = {
      target = "linux-x64";
      hash = "sha512-X614zHM4+iWOYn9ppU69vDYrgP6FAMQT51SRwz9QURFtdlaL27VWt1cCOEvC3qkseg0KRWjYfLInpje2WFJeLw==";
    };
    "aarch64-linux" = {
      target = "linux-arm64";
      hash = "sha512-qE4/PrlFfJ2sW6ZSFugpLcM5G3RkeWCGbYp7y91NMSwnqWVhDonlu8/ohNZKfgeQ72WleIoC01xOh+Wl5FXqAA==";
    };
    "x86_64-darwin" = {
      target = "darwin-x64";
      hash = "sha512-BLoGLGDG0XCcZo4rEILfS4aajriwT7jtxRszG+jqWd/xiaAPP4s6N68OufDZ9JxolGTq3W0jYxBxZIuP5VaCLg==";
    };
    "aarch64-darwin" = {
      target = "darwin-arm64";
      hash = "sha512-O3bHK9wUwgPWF+9RbI22hpDzItia2vhUy3wQIy6Q72+gaY+IBfXfcOZECqMrEvM6QOSFt7b6NOjcFxN2ykObSQ==";
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
