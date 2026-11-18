_:
(_final: prev: {
  mitmproxy = prev.mitmproxy.overrideAttrs (old: {
    disabledTests =
      (old.disabledTests or [ ])
      ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [ "test_emudhra" ];
  });
})
