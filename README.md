# Dotfiles

Two systems, built with flake-parts and nixos-unified:

- `darwinConfigurations.willmb`: Apple Silicon MacBook
- `nixosConfigurations.willnixos`: Apple Silicon NixOS VM with Niri

## Layout

- `configurations/` contains host identity, hardware, filesystems, and VM image details.
- `modules/{darwin,nixos}/` contains reusable system capabilities and role modules.
- `darwin/common/` is the shared macOS workstation profile.
- `home/profiles/` composes user roles from `home/modules/{cli,gui}/` capabilities.
- `overlays/` contains pinned packages and the small set of package-set additions.

Hosts, exported modules, and overlays are wired explicitly in
`modules/flake/toplevel.nix`; adding a file does not silently add a flake output.

## Commands

```sh
nix develop
nix fmt
nix flake check
nix flake check --no-build --all-systems
nix run .#activate
```

`nix run .#activate` selects the configuration matching the current hostname.

## Containers

The macOS configuration manages a Lima VZ instance named `docker`. It starts at
login and runs rootful Docker Engine. Home Manager configures the `lima-docker`
context for the standard Docker CLI:

```sh
docker run --rm hello-world
docker compose up
```

The host home is writable in this development VM so bind mounts beneath
`/Users/will` behave normally. Existing Colima data is deliberately left alone
until the Lima migration has been verified.

## SSH keys

SSH private keys live only in 1Password. The 1Password SSH agent serves
them to SSH and Git; no private key is written to the repository, home
directory, or a Nix generation.

Turn on the agent once in 1Password under Settings > Developer > Use the
SSH Agent, and keep 1Password running (menu bar / Start at login).

Home Manager points both `SSH_AUTH_SOCK` and `IdentityAgent` at the
portable `~/.1password/agent.sock` path. On macOS an activation step
symlinks that path to the 1Password socket, so the same SSH config works
on macOS and Linux:

```sh
ssh-add -l
ssh my-server
```

The SSH key item named `Primary SSH Key` is used for Git commit signing
via `op-ssh-sign`. Other SSH key items become available to the agent
automatically without rebuilding or activating Nix. The old SOPS and
SecretSpec provisioning are intentionally gone.

## Graphical NixOS VM

The `willnixos` configuration has a Lima image variant for an Apple
Virtualization.framework VM. It boots niri in Lima's native graphical window
and shares the macOS home read-only at `/mnt/host`.

```sh
nixos-vm create
nixos-vm start
nixos-vm rebuild
nixos-vm stop
```

`nixos-vm recreate` explicitly replaces the persistent VM after confirmation.
Normal configuration changes should use `nixos-vm rebuild` instead. Clipboard
integration is not currently configured.

## macOS ownership and exceptions

nix-darwin owns the hostnames, timezone, firewall, Remote Login, Dock/Finder
preferences, managed fonts, Nix-packaged Homebrew casks, and Mac App Store
receipts via nix-darwin's native `mas` module. These
remain intentional manual exceptions: GlobalProtect, Determinate Nix,
FileVault, Apple SF fonts, Vend Sans/Junction fonts, Mitmproxy Redirector, and
the authentication and profile data inside Helium.

The stale OrbStack, Proxyman, Zoom, Edge, ProtonVPN, and possible Tailscale
components recorded in `macos-drift-findings.md` require their owning
uninstallers or explicit verification; the Nix activation does not delete
privileged third-party data.
