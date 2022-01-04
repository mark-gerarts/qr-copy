{ pkgs ? import <nixpkgs> {}}:

with pkgs;

mkShell rec {
  buildInputs = [
    nodejs
    nodePackages.degit
  ];
}
