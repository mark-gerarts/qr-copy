{ pkgs ? import <nixpkgs> {}}:

with pkgs;

# Run:
#   $ nix-shell -p nodePackages.node2nix
#   $ node2nix -i package.json --development
#
# @see https://discourse.nixos.org/t/shell-nix-for-hugo-postcss/13865
let
  nodeEnv = callPackage ./node-env.nix { };
  nodePackages = callPackage ./node-packages.nix {
    globalBuildInputs = [ ];
    inherit nodeEnv;
  };
in nodePackages.shell
