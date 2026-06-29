{ staging, ... }:
(
  final: prev:
  let
    stagingPkgs = import staging {

      system = prev.stdenv.hostPlatform.system;
      config = prev.config or { };
    };
  in
  {
    nodejs = stagingPkgs.nodejs_22;
    nodejs-slim = stagingPkgs.nodejs-slim_22;

    nodejs_24 = stagingPkgs.nodejs_22;
    nodejs-slim_24 = stagingPkgs.nodejs-slim_22;
  }
)
