{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.neovix;

  lenguajesActivadosYConGramaticas =
    cfg.lenguajes
    |> lib.mapAttrsToList (
      clave: lenguaje: with lenguaje; if !activar || gramaticas == null then clave else null
    )
    |> builtins.filter (x: x != null)
    |> removeAttrs cfg.lenguajes;
in
{
  programs.neovix.complementos = lib.mkIf (cfg.activar && lenguajesActivadosYConGramaticas != { }) {
    "Treesitter" = {
      paquete = pkgs.vimPlugins.nvim-treesitter;
      dependencias =
        lenguajesActivadosYConGramaticas
        |> lib.mapAttrsToList (_: lenguaje: lenguaje.gramaticas)
        |> lib.lists.flatten;
      configuracion = /* lua */ ''
        require('nvim-treesitter').setup({
          highlight = { enable = true },
          indent = { enable = true },
        })
      '';
      lazy.eventos = [
        "BufReadPost"
        "BufNewFile"
      ];
    };
  };
}
