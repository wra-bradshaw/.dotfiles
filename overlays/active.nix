{ inputs }:
inputs.nixpkgs.lib.composeManyExtensions [
  (import ./annas-mcp.nix { })
  (import ./apfel-llm.nix { })
  (import ./helium.nix { })
  (import ./opencode.nix { })
  (_: prev: { snap = inputs.snap.packages.${prev.stdenv.hostPlatform.system}.default; })
]
