{ ... }:
(final: prev: {
  rift = prev.rustPlatform.buildRustPackage rec {
    pname = "rift";
    version = "0.3.7";
    src = prev.fetchFromGitHub {
      owner = "acsandmann";
      repo = "rift";
      rev = "v${version}";
      hash = "sha256-UZOlV0evc2o5SSKgxDnkhdbxFOc2NRvp25Jj2Ejc/zE=";
    };
    cargoHash = "sha256-A0huWauj3Ltnw39jFft6pyYUVcNK+lu89ZlVQl/aRZg=";

    buildInputs = [
      prev.apple-sdk_15
    ];
  };
})
