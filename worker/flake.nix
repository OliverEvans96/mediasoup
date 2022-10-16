{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, fenix, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rustPlatform = pkgs.rustPlatform;
        deps = with pkgs; [ python lld pkgconfig udev ninja ];
        pyDeps = with pkgs.python3Packages; [ pip meson ];
        allDeps = deps ++ pyDeps;
      in {
        defaultPackage = rustPlatform.buildRustPackage {
          pname = "mediasoup-nix";
          version = "0.1.0";

          nativeBuildInputs = allDeps;

          cargoLock = { lockFile = ./Cargo.lock; };

          src = ./.;
        };

        devShell = pkgs.mkShell {
          name = "mediasoup-nix-shell";
          src = ./.;

          # build-time deps
          nativeBuildInputs = allDeps;
        };
      });
}
