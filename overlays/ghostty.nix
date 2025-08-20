{ ... }:
(
  final: prev:
  let
    ghosttyDarwin = prev.stdenv.mkDerivation (finalAttrs: {
      pname = "ghostty";
      version = "nightly";

      src = prev.fetchurl {
        url = "https://github.com/ghostty-org/ghostty/releases/download/tip/Ghostty.dmg";
        hash = "sha256-2atVfbbGdYyp8uvYbgwhxz6zHzMAJJT37sLRqtiLP6o=";
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
      sourceRoot = "Ghostty.app";
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

      meta = {
        mainProgram = "ghostty";
      };
    });
  in
  {
    ghostty = if prev.stdenv.isDarwin then ghosttyDarwin else prev.ghostty;
  }
)
