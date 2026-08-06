{ pkgs, ... }: {
  home.packages = [
    (pkgs.aspellWithDicts (d: [
      d.en
      d.en-science
      d.en-computers
    ]))
  ];
}
