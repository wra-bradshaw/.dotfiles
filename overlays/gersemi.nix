# gersemi 0.29.2's rust-backend depends on rusqlite with the `bundled`
# feature, but nixpkgs' cargo-setup-hook unconditionally exports
# LIBSQLITE3_SYS_USE_PKG_CONFIG=1, which makes libsqlite3-sys link against
# the system sqlite instead of compiling its bundled amalgamation.
# Upstream pkgs/by-name/ge/gersemi/package.nix provides neither sqlite nor
# pkg-config, so the final cdylib link fails with:
#   ld.bfd: cannot find -lsqlite3: No such file or directory
# Work around it the same way gradient/nh/devenv do in nixpkgs: supply the
# system sqlite explicitly. Drop this once upstream adds sqlite to
# gersemi's buildInputs.
_: _final: prev: {
  gersemi = prev.gersemi.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ prev.sqlite ];
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.pkg-config ];
  });
}
