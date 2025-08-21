{ ... }:
(final: prev: {
  lldb = prev.lldb.overrideAttrs (oldAttrs: {
    postInstall = oldAttrs.postInstall + ''
      wrapProgram $out/bin/lldb ${prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin "--set-default LLDB_DEBUGSERVER_PATH '/Library/Developer/CommandLineTools/Library/PrivateFrameworks/LLDB.framework/Versions/A/Resources/debugserver'"}
    '';
  });
})
