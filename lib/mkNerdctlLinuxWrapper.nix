{
  lib,
  pkgs,
  crossPkgs,
  binName,
  name,
  contents,
  cmd ? [ ],
  env ? [ ],
}:
let
  containerImage = crossPkgs.dockerTools.buildLayeredImage {
    inherit name;
    tag = "latest";
    contents = [
      crossPkgs.busybox
      crossPkgs.cacert
    ]
    ++ contents;
    config = {
      Cmd = cmd;
      Env = [
        "PATH=/bin"
        "SSL_CERT_FILE=${crossPkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ]
      ++ env;
    };
  };
in
pkgs.writeShellScriptBin binName ''
  set -euo pipefail
  image_name=${lib.escapeShellArg "${name}:latest"}
  # Loading is content-addressed and refreshes the tag when the Nix image changes.
  nerdctl load < ${containerImage} >/dev/null
  exec nerdctl run -ti --rm \
    -v "$PWD:$PWD" \
    -v "tmp:/tmp" \
    -w "$PWD" \
    "$image_name" \
    ${binName} "$@"
''
