{ pkgs, ... }:
let
  provider = "openai-codex";

  solModelId = "gpt-5.6-sol";
  lunaModelId = "gpt-5.6-luna";

  solModel = "${provider}/${solModelId}";
in
{
  programs.pi-coding-agent = {
    enable = true;

    extraPackages = with pkgs; [
      nodejs
      git
      jq
      ripgrep
      fd
    ];

    settings = {
      defaultProvider = provider;
      defaultModel = lunaModelId;
      defaultThinkingLevel = "medium";

      npmCommand = [ "${pkgs.nodejs}/bin/npm" ];
      packages = [
        "npm:pi-subagents@0.34.0"
      ];

      subagents = {
        defaultModel = "${provider}/${lunaModelId}";

        agentOverrides = {
          advisor.model = solModel;
          advisor.thinking = "medium";

          scout.disabled = true;
          planner.disabled = true;
          worker.disabled = true;
          reviewer.disabled = true;
          context-builder.disabled = true;
          researcher.disabled = true;
          delegate.disabled = true;
          oracle.disabled = true;
        };
      };
    };
  };

  home.file.".pi/agent/agents/advisor.md".source = ../../pi/advisor.md;
  home.file.".pi/agent/extensions/main-only-advisor-policy.ts".source =
    ../../pi/main-only-advisor-policy.ts;

  home.file.".pi/agent/extensions/subagent/config.json".text = builtins.toJSON {
    turnBudget = {
      maxTurns = 100;
      graceTurns = 5;
    };
  };
}
