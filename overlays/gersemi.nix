_:
(_final: prev: {
  gersemi = prev.gersemi.overrideAttrs {
    dontCargoUseSystemLibs = true;
  };
})
