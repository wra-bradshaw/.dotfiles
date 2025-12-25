{ }:
(final: prev: {
  brewCasks = prev.brewCasks // {
    "zed@preview" = prev.brewCasks."zed@preview".overrideAttrs (
      finalAttrs: previousAttrs: {
        installPhase = ''
          ls "."
          pwd
          mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
          cp -R . "$out/Applications/${finalAttrs.sourceRoot}"

          makeWrapper "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/cli" $out/bin/zeditor
        '';
      }
    );
  };
})
