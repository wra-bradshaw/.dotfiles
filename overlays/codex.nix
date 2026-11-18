_:
(_final: prev: {
  codex = prev.codex.overrideAttrs {
    dontCargoUseSystemLibs = true;
  };
})
