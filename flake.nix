{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix.url = "github:nix-community/poetry2nix";
    poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, poetry2nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      pythonPackages = pkgs.python312Packages;
      python = pkgs.python312;

      inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
      krr = mkPoetryApplication {
        inherit python;
        projectDir = ./.;
        preferWheels = true;
      };

    in
    {

      packages.krr = krr;

      devShells.default = pkgs.mkShell {
        venvDir = ".venv";

        propagatedBuildInputs = with pkgs; [
          pythonPackages.setuptools
        ];

        buildInputs = with pkgs; [
          pythonPackages.venvShellHook
        ];

        packages = with pkgs; [
          python
          zlib
        ];

        postVenvCreation = ''
          # unset SOURCE_DATE_EPOCH
          pip install -r requirements.txt
        '';

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          pkgs.zlib
          pkgs.stdenv.cc.cc
        ];
      };
    }
    );
}
