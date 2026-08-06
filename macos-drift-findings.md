# macOS drift findings

Audit date: 2026-08-06
Host: `Wills-MacBook-Air.local` (`aarch64-darwin`)
Scope: read-only comparison of the running macOS system with this repository. No remediation was applied.

## Modernisation disposition

The dotfiles modernisation addresses the findings as follows:

- `willmb` now declares the computer, local, and network hostnames; Melbourne timezone; application firewall; Remote Login; Dock tile/hot-corner state; Finder path/status/list-view state; and the `/bin/zsh` login shell already used by the account.
- EB Garamond and Libertinus are managed declaratively. Junction and Vend Sans remain documented manual fonts because the available Nix packages do not support this Darwin platform. Licensed Apple fonts remain intentional exceptions.
- The observed Mac App Store receipts are declared through `programs.mas.packages`. Discord and Roblox are declared as casks. IntelliJ IDEA has been removed from the managed casks and uninstalled to Trash.
- GlobalProtect, Determinate Nix, FileVault, Apple fonts, Mitmproxy Redirector, and generated Helium PWAs remain intentional exceptions.
- Power-management and trackpad values remain unmanaged because the audit could not distinguish desired settings from defaults safely.
- Privileged stale helpers and system extensions are not deleted by Nix. OrbStack, Proxyman, Zoom, Edge, ProtonVPN, and Tailscale remain an explicit one-time cleanup/verification list requiring their owning uninstallers or user confirmation.

## Status definitions

- **Confirmed drift**: observed state is outside the repository or directly conflicts with it.
- **Likely drift**: observed state is not declared, but ownership or desired intent needs confirmation.
- **Intentional exception**: deliberately left outside Nix/Darwin management.
- **Verify**: there is not enough evidence to remove or adopt the item safely.

## Nix-Darwin generation

**Confirmed in sync.** The active Nix-Darwin profile is generation 83:

- `/nix/var/nix/profiles/system` -> `system-83-link`
- `/run/current-system` -> `/nix/store/dr9267kn96kqnby3izygp2pkhwprkxlm-darwin-system-26.11.15abb8c`
- Darwin label: `26.11.15abb8c`
- Repository evaluation: `nix eval --raw .#darwinConfigurations.macbookair.system.outPath` returned the same store path.
- Repository commit at audit time: `32c7c254bf4e8b7bd309926b2d76ff0c326a79e3`; the worktree was clean before this report was added.

The running generation therefore matches the current `macbookair` configuration. This confirms configuration identity, not that every mutable macOS preference still has its declared value.

## Applications outside Nix/Home Manager

Apps under `~/Applications/Home Manager Apps` are managed by the repository and are not drift. The generated Helium Gmail and Outlook PWAs are intentional exceptions. Apple-provided Safari and utilities are also excluded.

### Direct-install applications

| Status | Application | Bundle ID | Finding |
|---|---|---|---|
| Confirmed drift | Discord | `com.hnc.Discord` | Present in `/Applications`; only the Linux configuration declares Discord. |
| Confirmed drift | Roblox | `com.roblox.RobloxPlayer` | Present in `/Applications` and not declared. |
| Intentional exception | GlobalProtect | `com.paloaltonetworks.GlobalProtect.client` | Required externally; retain outside Nix management. |
| Verify | Mitmproxy Redirector | `org.mitmproxy.macos-redirector` | Root-owned app and active network extension. The repository declares `mitmproxy`, but the audit did not prove whether that package installed this app. Do not remove without testing redirector functionality. |

### Mac App Store applications

All of the following have a `_MASReceipt`, are absent from the repository, and are therefore **confirmed unmanaged applications**. Creator Studio-renamed apps are recorded by their installed names.

| Application | Bundle ID | App Store ID |
|---|---|---:|
| Compressor Creator Studio | `com.apple.CompressorApp` | `6746516157` |
| DaVinci Resolve | `com.blackmagic-design.DaVinciResolveLite` | `571213070` |
| Final Cut Pro Creator Studio | `com.apple.FinalCutApp` | `1631624924` |
| HEVCut | `dev.alepacheco.HEVCut` | `6737538832` |
| Keynote Creator Studio | `com.apple.Keynote` | `361285480` |
| Logic Pro Creator Studio | `com.apple.mobilelogic` | `1615087040` |
| MainStage Creator Studio | `com.apple.MainStageApp` | `6746637089` |
| Microsoft Excel | `com.microsoft.Excel` | `462058435` |
| Microsoft PowerPoint | `com.microsoft.Powerpoint` | `462062816` |
| Microsoft Word | `com.microsoft.Word` | `462054704` |
| Motion Creator Studio | `com.apple.motionappApp` | `6746637149` |
| Noir | `nl.jeffreykuiken.NoirApp.mac` | `1592917505` |
| Numbers Creator Studio | `com.apple.Numbers` | `361304891` |
| Pages Creator Studio | `com.apple.Pages` | `361309726` |
| Pixelmator Pro Creator Studio | `com.apple.pixelmator` | `6746662575` |
| Prodrafts | `emmo.prodrafts` | `1545810067` |
| TestFlight | `com.apple.TestFlight` | `899247664` |
| Vinegar | `com.andadinosaur.Vinegar` | `1591303229` |
| WhatsApp | `net.whatsapp.WhatsApp` | `310633997` |
| Wipr | `site.kaylees.Wipr2` | `1662217862` |

## Preferences and mutable system state

The repository already manages Dock autohide/animation/expose behaviour, Finder search scope and new-window location, screenshots, global keyboard/UI preferences, Caps Lock remapping, DNS, and several other defaults. The following observed values are not declared.

### Confirmed or likely drift

- **Likely drift — Dock:** tile size is `60`; the bottom-right hot corner is action `14` with modifier `0`.
- **Likely drift — Finder:** path bar enabled, status bar enabled, and preferred view style `Nlsv` (list view).
- **Likely drift — application firewall:** enabled, but `darwin/common` does not declare firewall policy.
- **Likely drift — power management:** custom `pmset` state exists for battery and AC power. Notable values include sleep after 1 minute, battery display sleep after 2 minutes, AC display sleep disabled, Power Nap enabled, and Wake-on-LAN enabled on AC. These may include macOS defaults and should be adopted only if intentional.
- **Likely drift — Remote Login:** the `com.openssh.sshd` system service is enabled, while the repository does not explicitly declare Remote Login.
- **Likely drift — timezone:** `/etc/localtime` points to `Australia/Melbourne`; it is not declared.
- **Verify — trackpad:** the preference domain records right-click enabled and three-finger drag disabled. Tap-to-click is declared globally, while the device-specific domain reports `Clicking = 0`; verify behaviour before trying to reconcile these domains.

## Fonts, printers, identity, shell, services, and extensions

### Fonts

- **Confirmed drift:** user-installed EB Garamond (2 files), Junction (3), Libertinus Sans (3), and Vend Sans (2) files are in `~/Library/Fonts` and are not declared.
- **Intentional exception:** SF Mono files in `/Library/Fonts` and SF Pro Display/Rounded/Text files in `~/Library/Fonts` are licensed Apple fonts. Keep them outside Nix rather than redistributing or fetching them declaratively.
- The repository's managed `Nix Fonts` location is separate from the files above.

### Printers

**No drift found.** CUPS reports no destinations and no default printer.

### Hostname and login shell

- **Confirmed drift:** `ComputerName` is `Will’s MacBook Air (3)` and `LocalHostName` is `Wills-MacBook-Air`; `HostName` is unset. None is declared in the repository.
- **Confirmed drift:** Directory Services records `/bin/zsh` as Will's login shell, while `users.users.will.shell = pkgs.zsh` declares the Nix-provided shell.

### Services and network state

- **Confirmed stale — OrbStack:** `/Library/LaunchDaemons/dev.orbstack.OrbStack.privhelper.plist` and `/Library/PrivilegedHelperTools/dev.orbstack.OrbStack.privhelper` remain, but no OrbStack app is installed.
- **Confirmed stale — Proxyman:** `/Library/LaunchDaemons/com.proxyman.NSProxy.HelperTool.plist` and `/Library/PrivilegedHelperTools/com.proxyman.NSProxy.HelperTool` remain, but no Proxyman app is installed.
- **Confirmed stale — Zoom:** two loaded user agents (`us.zoom.updater.gui.501` and `.login.check`) point to the absent `~/Applications/zoom.us.app`. Zoom application support, logs, receipts, HTTP storage, and updater data also remain.
- **Confirmed stale — Microsoft Edge:** the loaded `com.microsoft.EdgeUpdater.wake` agent and `~/Library/Application Support/Microsoft/EdgeUpdater` remain, but Microsoft Edge is absent.
- **Confirmed stale — ProtonVPN:** no ProtonVPN app is installed, but `ch.protonvpn.mac.WireGuard-Extension` is active and enabled, a `ProtonVPN` network service remains, and its container/application-script data remains.
- **Verify — Tailscale:** a `Tailscale` network service remains without an installed Tailscale app or listed system extension. Confirm whether it is still used before removing it.
- **Verify — Mitmproxy Redirector:** `org.mitmproxy.macos-redirector.network-extension` is active and enabled. Treat it as functional until its relationship to the declared `mitmproxy` package is confirmed.
- **Intentional exception — GlobalProtect:** its network extension remains registered (`activated waiting for user`) alongside the intentionally unmanaged application.
- **Intentional exception — Determinate Nix:** the `systems.determinate.*` launch daemons and installer receipt are the chosen Nix installation substrate; they are not configuration drift.
- Paneru, Neru, skhd, and socktainer launch jobs correspond to repository-managed configuration and are not drift. The old rbw-auth and sops-nix jobs are no longer declared.

## Intentional exceptions

The audit explicitly leaves these outside remediation:

- GlobalProtect and its system/network extension.
- Licensed Apple SF Mono and SF Pro fonts.
- FileVault, which is on; encryption state must not be altered by configuration cleanup.
- Determinate Nix and its launch daemons.
- Apple system applications and utilities.

## Candidate remediation (record only)

These are the choices recorded during the audit. They are proposals, not actions taken:

1. Remove the confirmed stale OrbStack and Proxyman helper daemon/plist pairs.
2. Unload and remove the confirmed stale Zoom and Edge updater agents, then remove their residual support data if no data retention is required.
3. Use the owning ProtonVPN uninstaller or macOS extension controls to remove the ProtonVPN extension, network service, and residual container data. Do not delete the system-extension bundle directly.
4. Decide whether Discord and Roblox should be declared through an available Nix/brew-cask package or retained as documented manual exceptions.
5. Record the wanted Mac App Store applications declaratively with `programs.mas.packages` using the IDs above. First verify which Creator Studio entitlements/names can be restored by `mas`; retain unsupported licensed apps as documented exceptions.
6. Package the non-Apple user fonts (EB Garamond, Junction, Libertinus Sans, and Vend Sans) declaratively if their sources and licences are suitable. Leave Apple fonts unmanaged.
7. Add explicit declarations for the desired computer/local hostname, timezone, Remote Login/firewall policy, Dock hot corner/tile size, Finder path/status/view settings, and intentional power-management values.
8. Reconcile the account shell with `pkgs.zsh` only after confirming that the Nix store shell path is present in `/etc/shells` and remains safe across generations.
9. Verify Tailscale and Mitmproxy Redirector before changing either. Preserve GlobalProtect, FileVault, Determinate Nix, Apple fonts, and generated PWAs.

No application, preference, font, service, extension, profile, hostname, shell, printer, or network configuration was changed during this audit.
