_:
(_final: prev: {
  annas-mcp = prev.buildGoModule (finalAttrs: {
    pname = "annas-mcp";
    version = "0.1";

    src = prev.fetchFromGitHub {
      owner = "iosifache";
      repo = "annas-mcp";
      tag = "v${finalAttrs.version}";
      hash = "sha256-4gH5175yA9YYPVifXX3n9WCTRug0gOOfpQBLaGbvBcU=";
    };

    vendorHash = "sha256-2NdG5p2XfrhVgi388dRDBUSGwg6ybnzfn9495TWNGsA=";

    meta = {
      mainProgram = "annas-mcp";
    };
  });
})
