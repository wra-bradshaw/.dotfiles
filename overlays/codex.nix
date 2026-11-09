# codex 0.167.0's rust backend depends on aws-lc-sys 0.45.0, and nixpkgs'
# cargo-setup-hook unconditionally exports AWS_LC_SYS_USE_SYSTEM=1 (see
# pkgs/build-support/rust/hooks/cargo-setup-hook.sh `cargoUseSystemLibs`),
# which forces aws-lc-sys to link against a system-installed AWS-LC instead
# of building from source. But pkgs/by-name/co/codex/package.nix only puts
# `openssl` in buildInputs, not `aws-lc`, so on darwin the build script
# probes the openssl-3.5.9-dev candidate, rejects it, and panics with:
#   AWS_LC_SYS_USE_SYSTEM=1 requires a system-installed AWS-LC, but none was found.
#   cargo:warning=Ignoring candidate AWS-LC at /nix/store/ckyrappyk5ap81c6ci1zcpcazdp7zwbq-openssl-3.5.9-dev: Failed to read .../include/openssl/base.h: No such file or directory (os error 2)
# Supply the system aws-lc explicitly, mirroring what nixpkgs'
# pkgs/build-support/rust/default-crate-overrides.nix does for aws-lc-sys
# >= 0.42.0 (buildInputs = [ aws-lc ], AWS_LC_SYS_USE_SYSTEM = 1) and what
# other top-level rust packages using aws-lc-sys do (e.g. jsonschema-cli,
# rustical both set buildInputs = [ aws-lc ]). Drop this once upstream
# nixpkgs adds aws-lc to codex's buildInputs.
_: _final: prev: {
  codex = prev.codex.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ prev.aws-lc ];
  });
}
