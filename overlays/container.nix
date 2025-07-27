{ ... }:
(final: prev: {
  brewCasks = prev.brewCasks // {
    container = prev.brewCasks.container.overrideAttrs (old: {
      unpackPhase = old.unpackPhase + ''
        zcat Payload | cpio -i
      '';
      installPhase = ''
        mkdir -p "$out/bin"
        mkdir -p "$out/libexec"
        cp -R bin/* "$out/bin"
        cp -a libexec/* "$out/libexec"
      '';
    });
  };
})
