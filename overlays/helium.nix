{ ... }:
(final: prev: {
  helium = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "helium";
    version = "0.13.3.1";

    src = prev.fetchurl {
      url = "https://github.com/imputnet/helium-macos/releases/download/${finalAttrs.version}/helium_${finalAttrs.version}_arm64-macos.dmg";
      hash = "sha256-4SeQxbnd9nFtWvUOFPbEFgFs1LFongXaA02UI2qfdnA=";
    };

    nativeBuildInputs = [
      prev._7zz
      prev.makeWrapper
    ];

    unpackPhase = ''
      7zz x -snld $src
    '';

    dontPatchShebangs = true;
    sourceRoot = "Helium.app";

    installPhase = ''
      mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
      cp -R . "$out/Applications/${finalAttrs.sourceRoot}"
      makeWrapper "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/${prev.lib.strings.removeSuffix ".app" finalAttrs.sourceRoot}" \
      $out/bin/${finalAttrs.pname};
    '';
  });
})
