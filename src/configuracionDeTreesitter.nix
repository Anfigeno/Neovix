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
      complementosDependientes =
        lenguajesActivadosYConGramaticas
        |> lib.mapAttrsToList (_: lenguaje: lenguaje.gramaticas)
        |> lib.lists.flatten;
      configuracion = /* lua */ ''
        vim.opt.rtp:prepend("${pkgs.vimPlugins.nvim-treesitter}/runtime/")

        require('nvim-treesitter').setup({ indent = { enable = true } })

        vim.api.nvim_create_autocmd('FileType', {
          pattern = ${lib.generators.toLua { } (cfg.lenguajes |> lib.mapAttrsToList (nombre: _: nombre))},
          callback = function()
            vim.treesitter.start()

            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo.foldmethod = 'expr'
          end,
        })
      '';
      lazy.activar = false;
    };
  };
}
