{ pkgs, ... }: { home.packages = with pkgs; [ brewCasks.slack brewCasks.notion ]; }
