{ config, ... }:
let
  extraCaCerts = "${config.home.homeDirectory}/.config/certs/claude-extra-ca.pem";
in
{
  home.file.".config/certs/claude-extra-ca.pem".source = ./certs/claude-extra-ca.pem;

  home.sessionVariables = {
    CLAUDE_CODE_CERT_STORE = "bundled,system";
    NODE_EXTRA_CA_CERTS = extraCaCerts;
  };

  # The opencode server runs under launchd/systemd, which don't read shell
  # session variables. Without this, the Claude Agent SDK it spawns can't
  # verify the TLS-inspecting proxy's certificate.
  services.opencode-serve.extraEnvironment.NODE_EXTRA_CA_CERTS = extraCaCerts;
}
