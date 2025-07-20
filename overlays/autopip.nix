{ ... }:
(final: prev: {
  autopip = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "autopip";
    version = "0.4";
    src = prev.fetchurl {
      url = "https://github.com/vordenken/AutoPiP/releases/download/v${finalAttrs.version}/AutoPiP.dmg";
      hash = "sha256-tXbK6+8nHqLYB9XS9BPSLAJtqpdhCAWFWh2+Dm3k9B0=";
    };
    nativeBuildInputs = [
      prev._7zz
      prev.darwin.sigtool
      prev.findutils
      prev.gnugrep
      prev.gawk
    ];
    unpackPhase = ''
      7zz x -snld $src
    '';
    dontPatchShebangs = true;
    sourceRoot = "AutoPiP.app";
    installPhase = ''
      mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
      cp -R . "$out/Applications/${finalAttrs.sourceRoot}"
      find "$out/Applications/${finalAttrs.sourceRoot}" -type f \
      \( -name "*.dylib" -o -name "*.so" -o -name "*.framework" -o -name "*.app" -o -name "*.plugin" -o -name "*.appex" -o -name "*.bundle" \) \
      -print0 | \
      xargs -0 sh -c 'file "$@" | \
      grep -E "Mach-O (64-bit |32-bit )?executable" | \
      awk -F: "{print \$1}" | \
      xargs -I {} codesign --force -s - "{}"' _
    '';
  });
})
