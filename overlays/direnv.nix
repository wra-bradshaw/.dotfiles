{ ... }:
(final: prev: {
  direnv = prev.direnv.overrideAttrs (oldAttrs: {
    doCheck = false;
  });
})
