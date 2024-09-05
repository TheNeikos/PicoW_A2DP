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

        pico-sdk = pkgs.fetchFromGitHub {
          owner = "raspberrypi";
          repo = "pico-sdk";
          rev = "1.5.1";
          sha256 = "sha256-GY5jjJzaENL3ftuU5KpEZAmEZgyFRtLwGVg3W1e/4Ho=";
          fetchSubmodules = true;
        };

        pico-extra = pkgs.fetchFromGitHub {
          owner = "raspberrypi";
          repo = "pico-extras";
          rev = "sdk-1.5.1";
          sha256 = "sha256-mnK8BhtqTOaFetk3H7HE7Z99wBrojulQd5m41UFJrLI=";
          fetchSubmodules = true;
        };

        pico-adw2 = pkgs.stdenv.mkDerivation {
          pname = "pico-adw2";
          version = "0.1.0";
          src = pkgs.lib.cleanSource ./.;

          PICO_SDK_PATH = pico-sdk;
          PICO_EXTRAS_PATH = pico-extra;

          buildInputs = [
            pico-sdk
            pico-extra
          ];

          cmakeFlags = [
            "-DPICO_SDK_PATH=${pico-sdk}"
            "-DCMAKE_C_COMPILER=${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-gcc"
            "-DCMAKE_CXX_COMPILER=${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-g++"
          ];

          nativeBuildInputs = with pkgs; [
            gcc-arm-embedded
            picotool
            python3
            cmake
            gnumake
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out

            cp -v picow-a2dp.uf2 $out/

            runHook postInstall
          '';
        };

      in
      rec {
        packages.pico-a2dp = pico-adw2;

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
