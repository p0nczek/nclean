{
  description = "nix-sweeper: curses TUI for managing NixOS generations";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "nix-sweeper";
            version = "1.0.0";

            dontUnpack = true;
            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              install -Dm755 ${./nclean.py} $out/bin/.nix-sweeper-unwrapped
              makeWrapper ${pkgs.python3}/bin/python3 $out/bin/nix-sweeper \
                --add-flags $out/bin/.nix-sweeper-unwrapped \
                --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nh ]}
            '';

            meta = with pkgs.lib; {
              description = "Curses TUI for managing NixOS generations";
              license = licenses.mit;
              platforms = platforms.linux;
              mainProgram = "nix-sweeper";
            };
          };
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nix-sweeper";
        };
      });
    };
}
