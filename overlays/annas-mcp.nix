{ ... }:
(final: prev: {
  annas-mcp = prev.buildGoModule (finalAttrs: {
    pname = "annas-mcp";
    version = "0.0.5";

    src = prev.fetchFromGitHub {
      owner = "iosifache";
      repo = "annas-mcp";
      tag = "v${finalAttrs.version}";
      hash = "sha256-XicM7tU5jD8B8n7JJDQ/84koBiLb8XF4+WBQ4LCUoRU=";
    };

    vendorHash = "sha256-2NdG5p2XfrhVgi388dRDBUSGwg6ybnzfn9495TWNGsA=";

    meta = {
      mainProgram = "annas-mcp";
    };
  });
})
