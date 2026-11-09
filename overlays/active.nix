{ inputs }:
inputs.nixpkgs.lib.composeManyExtensions [
  (import ./annas-mcp.nix { })
  (import ./apfel-llm.nix { })
  (import ./chrome-devtools-mcp.nix { })
  (import ./foqos.nix { })
  (import ./gersemi.nix { })
  (import ./helium.nix { })
  (import ./ical.nix { })
  (import ./mitmproxy.nix { })
  (import ./ntn.nix { })
  (import ./opencode.nix { })
  (import ./rex-app.nix { })
  (_: prev: { snap = inputs.snap.packages.${prev.stdenv.hostPlatform.system}.default; })
  (_: prev: { cf-nix-cache = inputs.cf-nix-cache.packages.${prev.stdenv.hostPlatform.system}.cli; })
]
