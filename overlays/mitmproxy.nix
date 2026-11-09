# mitmproxy 12.3.0's test_emudhra deliberately builds TLS chains with the
# compromised eMudhra intermediate CA key, but CPython's ssl module distrusts
# that key since the 3.13.18/3.14.10 security releases
# (https://github.com/python/cpython/issues/160040), so both parametrized
# cases fail in checkPhase with:
#   ssl.SSLCertVerificationError: [SSL: CERTIFICATE_VERIFY_FAILED]
#   certificate verify failed: certificate rejected (_ssl.c:1085)
# Backport the upstream test fix, which verifies the handshake with
# mitmproxy's own TLS client instead of CPython's ssl module:
# https://github.com/mitmproxy/mitmproxy/commit/992052ee92d7ff4d240eafbe1afdf87c94b3f080
# This is the same patch upstream nixpkgs carries for mitmproxy 12.3.1.
# Drop this once nixpkgs' mitmproxy expression contains the fix itself.
_: _final: prev: {
  python3Packages = prev.python3Packages.overrideScope (
    _self: super: {
      mitmproxy = super.mitmproxy.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.fetchpatch {
            name = "fix-test-emudhra.patch";
            url = "https://github.com/mitmproxy/mitmproxy/commit/992052ee92d7ff4d240eafbe1afdf87c94b3f080.patch";
            hash = "sha256-kxCt72m8G+yoAWe8xsXjt1U6B2Sh02u8MCFiqi18lng=";
          })
        ];
      });
    }
  );
}
