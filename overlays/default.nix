{ nur, brew-nix, ... }:
[
  (nur.overlays.default)
  (brew-nix.overlays.default)
  (import ./shortcat.nix { })
  (import ./rimage.nix { })
  (import ./autopip.nix { })
  (import ./container.nix { })
  (import ./ghostty.nix { })
  (import ./lldb.nix { })
  (import ./messenger.nix { })
  (import ./socktainer.nix { })
]
