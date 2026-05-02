{ ... }:
(final: prev: {
  rift = prev.rustPlatform.buildRustPackage rec {
    pname = "rift";
    version = "0.4.0";
    src = prev.fetchFromGitHub {
      owner = "acsandmann";
      repo = "rift";
      rev = "v${version}";
      hash = "sha256-3TKhoLJE+GtTfcnskH7yUBamCV+G5xXzy1n15mNWDzk=";
    };
    cargoHash = "sha256-2KMEjAGWxMzcY9yE5v9SmAspA4tDJtNwS0GlEm4opKc=";

    buildInputs = [
      prev.apple-sdk_15
    ];
  };
})
