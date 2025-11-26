{ ... }:
(final: prev: {
  lldb =
    if prev.stdenv.isDarwin then
      (prev.stdenv.mkDerivation (finalAttrs: {
        pname = "lldb";
        version = prev.lib.getVersion prev.lldb;
        src = prev.lldb;
        dontUnpack = true;
        dontBuild = true;

        nativeBuildInputs = [
          prev.makeWrapper
        ];

        installPhase = ''
          cp -R $src "$out";
        '';

        postInstall = ''
          wrapProgram $out/bin/lldb ${prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin "--set-default LLDB_DEBUGSERVER_PATH '/Library/Developer/CommandLineTools/Library/PrivateFrameworks/LLDB.framework/Versions/A/Resources/debugserver'"}
        '';
      }))
    else
      prev.lldb;
})
