{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.neovix;

  lenguajesActivadosYConFormateadores =
    cfg.lenguajes
    |> lib.mapAttrsToList (
      clave: lenguaje: with lenguaje; if !activar || formateadores == null then clave else null
    )
    |> builtins.filter (x: x != null)
    |> removeAttrs cfg.lenguajes;

  formateadoresEnUso =
    lenguajesActivadosYConFormateadores
    |> lib.mapAttrsToList (_: lenguaje: lenguaje.formateadores)
    |> lib.lists.flatten
    |> lib.unique
    |> (
      x:
      cfg.formateadores
      |> lib.mapAttrsToList (clave: formateador: if !(builtins.elem clave x) then clave else null)
      |> builtins.filter (x: x != null)
    )
    |> removeAttrs cfg.formateadores;
in

lib.mkIf (cfg.activar && lenguajesActivadosYConFormateadores != { }) {
  home.packages =
    formateadoresEnUso
    |> lib.mapAttrsToList (_: formateador: formateador.paquete)
    |> builtins.filter (x: x != null);

  programs.neovix.complementos."Conform" = {
    paquete = pkgs.vimPlugins.conform-nvim;
    configuracion =
      let
        configuracionDeFormateadores =
          formateadoresEnUso
          |> lib.mapAttrsToList (
            nombre: formateador:
            if formateador.configuracion == null then
              null
            else
              /* lua */ ''
                require("conform").formatters.${nombre} = ${lib.generators.toLua { } formateador.configuracion}
              ''
          )
          |> builtins.filter (x: x != null)
          |> builtins.concatStringsSep "\n";

        configuracionDeConform =
          {
            formatters_by_ft =
              lenguajesActivadosYConFormateadores
              |> lib.mapAttrsToList (
                clave: lenguaje: {
                  name = clave;
                  value = lenguaje.formateadores;
                }
              )
              |> builtins.listToAttrs;
          }
          |> lib.generators.toLua { }
          |> (x: /* lua */ ''require("conform").setup(${x})'');

        confi =
          [
            configuracionDeConform
            configuracionDeFormateadores
          ]
          |> builtins.concatStringsSep "\n\n";
      in
      confi;

    lazy.teclas = {
      "<s-f>" = {
        accion = /* lua */ ''require("conform").format({ bufnr = vim.api.nvim_get_current_buf() }) '';
        descripcion = "Formatea el buffer";
      };
    };
  };
}
