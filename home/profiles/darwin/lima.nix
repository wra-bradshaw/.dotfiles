{ config, ... }:
{
  services.lima = {
    enable = true;
    instances.docker = {
      autostart = true;
      settings = {
        base = [ "template:docker-rootful" ];
        provision = [
          {
            mode = "system";
            script = ''
              #!/bin/bash
              set -euo pipefail

              host_gateway_ip="$(getent ahostsv4 host.lima.internal | awk 'NR == 1 { print $1 }')"
              if [[ -z "$host_gateway_ip" ]]; then
                echo "Could not resolve host.lima.internal" >&2
                exit 1
              fi

              daemon_changed="$(python3 - "$host_gateway_ip" <<'PY'
              import json
              import sys
              from pathlib import Path

              path = Path("/etc/docker/daemon.json")
              data = json.loads(path.read_text()) if path.exists() else {}
              host_gateway_ips = data.setdefault("host-gateway-ips", [])
              changed = sys.argv[1] not in host_gateway_ips
              if changed:
                  host_gateway_ips.append(sys.argv[1])
                  path.write_text(json.dumps(data, indent=2) + "\n")
              print("changed" if changed else "unchanged")
              PY
              )"
              if [[ "$daemon_changed" == "changed" ]]; then
                systemctl restart docker
              fi
            '';
          }
        ];
        vmType = "vz";
        arch = "aarch64";
        cpus = 4;
        memory = "4GiB";
        disk = "100GiB";
        mountType = "virtiofs";
        vmOpts.vz.rosetta = {
          enabled = true;
          binfmt = true;
        };
        mounts = [
          {
            location = config.home.homeDirectory;
            writable = true;
          }
        ];
      };
    };
  };
}
