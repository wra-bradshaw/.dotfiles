{
  pkgs,
  crossPkgs,
  binName,
  name,
  contents,
  cmd ? [ ],
  env ? [ ],
}:
let
  dockerImage = crossPkgs.dockerTools.buildLayeredImage {
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
  layerDigestsDerivation = pkgs.stdenv.mkDerivation {
    name = "${name}-layer-digests";
    src = dockerImage;
    buildInputs = [ pkgs.jq ];
    phases = [
      "unpackPhase"
      "buildPhase"
    ];
    unpackPhase = "tar -xf $src";
    buildPhase = ''
      layers=$(jq -r '.[0].Layers[]' manifest.json)
      digests=()
      for layer in $layers; do
        digest=$(tar -xOzf $src "$layer" | sha256sum | awk '{print $1}')
        digests+=("\"$digest\"")
      done
      printf '[%s]\n' "$(IFS=,; echo "''${digests[*]}")" > $out
    '';
  };
in
pkgs.writeShellScriptBin binName ''
  set -euo pipefail
  IMAGE_PATH="${dockerImage}"
  IMAGE_NAME="${name}:latest"
  CACHED_JSON_FILE="${layerDigestsDerivation}"
  cached_json=$(cat "$CACHED_JSON_FILE")
  if docker_json=$(docker image inspect "$IMAGE_NAME" 2>/dev/null | jq -r '.[0].RootFS.Layers | map(sub("sha256:"; ""))' 2>/dev/null); then
    :
  else
    docker_json='[]'
  fi
  sorted_cached=$(echo "$cached_json" | jq -c 'sort')
  sorted_docker=$(echo "$docker_json" | jq -c 'sort')
  if [[ "$sorted_cached" != "$sorted_docker" ]]; then
    echo "Loading ${name} Docker image..."
    docker load < "$IMAGE_PATH"
  fi
  exec docker run -ti --rm -v "$PWD:$PWD" -v "/nix/store:/nix/store" -v "tmp:/tmp" -w "$PWD" "$IMAGE_NAME" ${binName} "$@"
''
