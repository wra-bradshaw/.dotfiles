_:
(_final: prev: {
  chrome-devtools-mcp = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "chrome-devtools-mcp";
    version = "1.12.0";

    src = prev.fetchurl {
      url = "https://registry.npmjs.org/chrome-devtools-mcp/-/chrome-devtools-mcp-${finalAttrs.version}.tgz";
      hash = "sha256-Sq3jFnw+eBx5fWEJ7WA6DKW4yzY6KJ4uqsqpsMXSo2A=";
    };

    nativeBuildInputs = [ prev.makeWrapper ];

    # Own Node runtime for the MCP server, independent of environment node.
    # Upstream requires Node ^20.19 || ^22.12 || >=23.
    buildInputs = [ prev.nodejs_24 ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/chrome-devtools-mcp
      cp -R build skills package.json LICENSE README.md $out/lib/chrome-devtools-mcp/
      mkdir -p $out/bin
      makeWrapper ${prev.nodejs_24}/bin/node $out/bin/chrome-devtools-mcp \
        --add-flags "$out/lib/chrome-devtools-mcp/build/src/bin/chrome-devtools-mcp.js" \
        --set CHROME_DEVTOOLS_MCP_NO_UPDATE_CHECKS 1
      makeWrapper ${prev.nodejs_24}/bin/node $out/bin/chrome-devtools \
        --add-flags "$out/lib/chrome-devtools-mcp/build/src/bin/chrome-devtools.js" \
        --set CHROME_DEVTOOLS_MCP_NO_UPDATE_CHECKS 1
      runHook postInstall
    '';

    meta = {
      description = "Chrome DevTools MCP server (hermetic, with own Node runtime)";
      homepage = "https://github.com/ChromeDevTools/chrome-devtools-mcp";
      license = prev.lib.licenses.asl20;
      mainProgram = "chrome-devtools-mcp";
      platforms = prev.lib.platforms.all;
    };
  });
})
