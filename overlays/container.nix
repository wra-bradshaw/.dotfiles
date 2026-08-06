{ ... }:
(final: prev: {
  container = prev.container.overrideAttrs (
    finalAttrs: _: {
      version = "1.2.0";
      src = final.fetchurl {
        url = "https://github.com/apple/container/releases/download/${finalAttrs.version}/container-${finalAttrs.version}-installer-signed.pkg";
        hash = "sha256-0UDUB2/wWT1rT3xYcicXsqvofXVFLP4KIDeSun9I8Hw=";
      };
    }
  );
})
