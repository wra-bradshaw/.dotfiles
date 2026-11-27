_:
(_final: prev: {
  opencode-antigravity-acp = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "opencode-antigravity-acp";
    version = "0.2.2";

    src = prev.fetchurl {
      url = "https://registry.npmjs.org/opencode-antigravity-acp/-/opencode-antigravity-acp-${finalAttrs.version}.tgz";
      hash = "sha256-ByNZ5kifKjNWxk5zTRsaPkIN1zScdRX8/ofJI0YYhFg=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R dist src package.json LICENSE README.md "$out/"
      runHook postInstall
    '';

    meta = {
      description = "OpenCode plugin bridging Google Antigravity models via local agy acp";
      homepage = "https://github.com/system1970/opencode-antigravity-acp";
      license = prev.lib.licenses.mit;
      platforms = prev.lib.platforms.all;
    };
  });
})
