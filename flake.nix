{
    description = "ESP-32 Rust dev environment";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs { inherit system; };
        in rec {
            # rust toolchain for esp
            idf-rust = pkgs.stdenv.mkDerivation {
                name = "idf-rust";
                src = pkgs.dockerTools.pullImage {
                    # rust toolchain for esp development
                    # once the rust version gets to old update to new package
                    # https://hub.docker.com/r/espressif/idf-rust/tags
                    imageName = "espressif/idf-rust";
                    imageDigest = "sha256:d8e62ceb2489c4186ea71fd935216ad552482bab5c31ff4666d0666ff4dc83d5";
                    sha256 = "sha256-dbDdqlKkj4HF+bIPa2rKuLJrm+b7tpNq/4oQANRF1Rc=";
                    finalImageTag = "all_latest";
                };
                unpackPhase = ''
                    mkdir -p source
                    tar -C source -xvf $src
                '';
                sourceRoot = "source";
                nativeBuildInputs = with pkgs; [
                    autoPatchelfHook
                    jq
                ];
                buildInputs = with pkgs; [
                    xz
                    zlib
                    libxml2
                    # python2
                    libudev-zero
                    stdenv.cc.cc
                ];
                buildPhase = ''
                    jq -r '.[0].Layers | @tsv' < manifest.json > layers
                '';
                installPhase = ''
                    mkdir -p $out
                    for i in $(< layers); do
                        tar -C $out -xvf "$i" home/esp/.cargo home/esp/.rustup || true
                    done
                    mv -t $out $out/home/esp/{.cargo,.rustup}
                    rmdir $out/home/esp
                    rmdir $out/home
                    # [ -d $out/.cargo ] && [ -d $out/.rustup ]
                '';
            };

            devShells.default = pkgs.mkShell {
                # packages to install
                buildInputs = with pkgs; [
                    bashInteractive # fixes console in vscode

                    cargo-generate # generate rust projects from github templates
                    cargo-udeps # find unused dependencies in Cargo.toml

                    # required for esp development
                    espflash    # flash binary to esp
                ] ++ [
                    idf-rust
                ];

                # execute some commands before environment is accessible
                shellHook = ''
                    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${
                        pkgs.lib.makeLibraryPath (with pkgs; [
                            stdenv.cc.cc
                            libxml2
                            libz
                        ])
                    }"
                    export PATH="$PATH:${idf-rust}/.rustup/toolchains/esp/bin"
                    export PATH="$PATH:${idf-rust}/.cargo/bin"
                    export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"

                    echo -e "\e[1mInstalling ldproxy"
                    echo -e "------------------\e[0m"
                    cargo install ldproxy
                '';
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
