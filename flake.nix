{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells = pkgs.mkShell {
          buildInputs = with pkgs; [
            opelssl
            pkg-config
            rust-analyzer
            cargo-deny
            cargo-edit
            cargo-watch
            cargo-insta
            probe-rs-tools
            minicom
            gdb
            cargo-binutils
            rust-bin.selectLatestNightlyWith
            (
              toolchain:
              toolchain.default.override {
                extensions = [
                  "rust-src"
                  "rust-fmt"
                  "clippy"
                  "llvm-tools"
                ];
              }
            )
          ];

          env = {
            RUST_SRC_PATH = "{pkgs.rust-bin}/lib/rustlib/src/rust/library";
          };

        };
      }
    );

}
