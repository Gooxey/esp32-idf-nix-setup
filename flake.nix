{
    description = "ESP-32 Rust dev environment";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        rust-overlay.url = "github:oxalica/rust-overlay";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs { inherit system; };
        in {
            devShells.default = pkgs.mkShell {
                # packages to install
                buildInputs = with pkgs; [
                    bashInteractive # fixes console in vscode

                    cargo-generate # generate rust projects from github templates
                    cargo-udeps # find unused dependencies in Cargo.toml

                    # required for esp development
                    espup       # tool for installing esp-rs toolchain
                    rustup      # rust installer, required by espup
                    espflash    # flash binary to esp
                    python3
                ];

                # execute some commands before environment is accessible
                shellHook = ''
                    echo -e "\e[1mInstalling toolchains for esp"
                    echo -e "-----------------------------\e[0m"
                    espup install
                    . ~/export-esp.sh

                    echo
                    echo -e "\e[1mInstalling ldproxy"
                    echo -e "------------------\e[0m"
                    cargo install ldproxy
                '';

                # https://github.com/Mic92/nix-ld
                NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
                    pkgs.stdenv.cc.cc
                    pkgs.libxml2
                ];
                NIX_LD = (pkgs.runCommand "ld.so" {} ''
                    ln -s "$(cat '${pkgs.stdenv.cc}/nix-support/dynamic-linker')" $out
                '');
            };
        }
    );

    # use prebuilt binaries
    nixConfig = {
        extra-substituters = [
            "https://nix-community.cachix.org"
            "https://cache.nixos.org/"
        ];
        extra-trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
    };
}
