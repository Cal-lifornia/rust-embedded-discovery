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
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs =
              [
                openssl
                pkg-config
                rust-analyzer
                cargo-deny
                cargo-edit
                cargo-watch
                cargo-insta
                probe-rs-tools
                minicom
                cargo-binutils
                (rust-bin.selectLatestNightlyWith (
                  toolchain:
                  toolchain.default.override {
                    extensions = [
                      "rust-src"
                      "rustfmt"
                      "clippy"
                      "llvm-tools"
                    ];
                    targets = [ "thumbv7em-none-eabihf" ];
                  }
                ))
              ]
              ++ (lib.optionals pkg.stdenv.isLinux [
                gdb
                usbutils
              ])
              ++ (lib.optionals pkg.stdenv.isDarwin [
                gcc-arm-embedded
                darwin.lsusb
              ]);

            env = {
              # RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";
            };

          };
      }
    );

}
