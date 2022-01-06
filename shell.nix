{ pkgs ? import <nixpkgs> {}}:

with pkgs;

# https://discourse.nixos.org/t/shell-nix-for-hugo-postcss/13865
let
  nodeEnv = callPackage ./node-env.nix { };
  nodePackages = callPackage ./node-packages.nix {
    globalBuildInputs = [ ];
    inherit nodeEnv;
  };
in nodePackages.shell
