_:
(_final: prev: {
  # TODO: Remove workaround: test_emudhra fails on darwin since CPython 3.14.10 distrusts the eMudhra test key; drop once nixpkgs has mitmproxy 12.3.1, which carries https://github.com/mitmproxy/mitmproxy/commit/992052ee92d7ff4d240eafbe1afdf87c94b3f080
  mitmproxy = prev.mitmproxy.overrideAttrs (old: {
    disabledTests =
      (old.disabledTests or [ ])
      ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [ "test_emudhra" ];
  });
})
