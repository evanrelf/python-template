{
  description = "template";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs@{ flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs =
          import nixpkgs {
            inherit system;
            overlays = [
              inputs.poetry2nix.overlays.default
            ];
          };

        poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };
      in
      rec {
        packages = {
          default = packages.template;

          template = poetry2nix.mkPoetryApplication { projectDir = ./.; };
        };

        devShells = {
          default = devShells.template;

          template = pkgs.mkShell {
            inputsFrom = [ packages.template ];
            packages = [
              pkgs.poetry
              pkgs.ruff
            ];
          };
        };

        checks = packages // devShells;
      });
}
