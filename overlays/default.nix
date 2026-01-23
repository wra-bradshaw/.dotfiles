{
  nur,
  brew-nix,
  komorebi-for-mac,
  neru,
  ...
}:
[
  (komorebi-for-mac.overlays.default)
  (nur.overlays.default)
  (brew-nix.overlays.default)
  (neru.overlays.default)
  (import ./zed-editor.nix { })
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
]
