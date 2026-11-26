{ inputs }:
inputs.nixpkgs.lib.composeManyExtensions [
  (import ./annas-mcp.nix { })
  (import ./apfel-llm.nix { })
  (import ./chrome-devtools-mcp.nix { })
  (import ./foqos.nix { })
  (import ./git-credential-manager.nix { })
  (import ./harlequin.nix { inherit inputs; })
  (import ./helium.nix { })
  (import ./hex.nix { })
  (import ./ical.nix { })
  (import ./ntn.nix { })
  (import ./opencode.nix { })
  (import ./rex-app.nix { })
  (import ./vtsls.nix { inherit inputs; })
  (_: prev: { snap = inputs.snap.packages.${prev.stdenv.hostPlatform.system}.default; })
  (_: prev: { cf-nix-cache = inputs.cf-nix-cache.packages.${prev.stdenv.hostPlatform.system}.cli; })
]
