{ }:
(final: prev: {
  zed-editor = prev.zed-editor.overrideAttrs (oldAttrs: {
    version = "0.218.2";
  });
})
