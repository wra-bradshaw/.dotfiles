{ ... }:
(final: prev: {
  rimage = prev.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "rimage";
    version = "0.12.3";

    src = prev.fetchFromGitHub {
      owner = "SalOne22";
      repo = "rimage";
      tag = "v${finalAttrs.version}";
      hash = "sha256-I7nOvxRORdZeolBABt5u94Ij0PI/AiLi4wbN+C02haQ=";
    };

    cargoHash = "sha256-kfOzzVkxHDqVrhX6vZF18f9hAXK9SKwezJphH0QGE4E=";

    cargoBuildFlags = [
      "--features"
      "build-binary,threads,metadata,resize,quantization,mozjpeg,oxipng,webp,avif,tiff,icc,console"
    ];

    nativeBuildInputs = [
      prev.cmake
      prev.perl
    ];
  });
})
