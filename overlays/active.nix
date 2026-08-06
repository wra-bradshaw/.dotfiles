{ inputs }:
final: prev:
let
  merge = overlays: prev.lib.foldl' (acc: overlay: acc // overlay final prev) { } overlays;
in
merge [
  (import ./annas-mcp.nix { })
  (import ./apfel-llm.nix { })
  (import ./helium.nix { })
  (import ./opencode.nix { })
  (_: _: { snap = inputs.snap.packages.${prev.stdenv.hostPlatform.system}.default; })
  (
    _: _:
    let
      jupyterServerWithoutTests =
        python:
        python.override {
          packageOverrides = _: pythonPrev: {
            jupyter-server = pythonPrev.jupyter-server.overridePythonAttrs {
              doCheck = false;
            };
          };
        };
    in
    {
      python313 = jupyterServerWithoutTests prev.python313;
      python314 = jupyterServerWithoutTests prev.python314;
    }
  )
]
