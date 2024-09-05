{
  description = "The CloudMQTT Rust library";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      rec {
        checks = {
        };

        devShells.default = devShells.cloudmqtt;
        devShells.cloudmqtt = pkgs.mkShell {
          buildInputs = [ ];

          nativeBuildInputs = with pkgs; [
            cmake
            gnumake
            gcc-arm-embedded
            picotool
            python3
            pico-sdk
          ];
        };
      }
    );
}
