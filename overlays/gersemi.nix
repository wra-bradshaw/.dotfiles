_:
(_final: prev: {
  # TODO: Remove workaround: nixpkgs' cargoUseSystemLibs hook forces libsqlite3-sys onto system sqlite, which gersemi doesn't provide ('cannot find -lsqlite3'); drop once nixpkgs gersemi builds with the hook
  gersemi = prev.gersemi.overrideAttrs {
    dontCargoUseSystemLibs = true;
  };
})
