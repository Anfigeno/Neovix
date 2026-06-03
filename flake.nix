{
  description = "Envoltorio de Neovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      moduloHM = ./src/opcion.nix;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixd
          nil
          nixfmt
        ];
      };
    };
}
