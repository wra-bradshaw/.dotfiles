{
  nur,
  brew-nix,
  komorebi-for-mac,
  neru,
  snap,
  ...
}:
[
  (komorebi-for-mac.overlays.default)
  (nur.overlays.default)
  (brew-nix.overlays.default)
  (neru.overlays.default)
  (import ./apfel-llm.nix { })
  (import ./annas-mcp.nix { })
  (import ./rift.nix { })
  (import ./shortcat.nix { })
  (import ./rimage.nix { })
  (import ./autopip.nix { })
  (import ./container.nix { })
  (import ./lldb.nix { })
  (import ./messenger.nix { })
  (import ./socktainer.nix { })
  (import ./helium.nix { })
  (import ./macos-wallpaper.nix { })
  (import ./glide.nix { })
  (import ./omniwm.nix { })
  (import ./direnv.nix { })
  (import ./opencode.nix { })
  (import ./codex.nix { })
  (import ./pi-coding-agent.nix)
  (import ./modrinth.nix { })
  (import ./snap.nix { inherit snap; })
]
