{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.neovix;

  lenguajesActivosYConEntornosDeEjecucion =
    cfg.lenguajes
    |> lib.mapAttrsToList (
      clave: lenguaje: if !lenguaje.activar || lenguaje.entornoDeEjecucion == null then clave else null
    )
    |> builtins.filter (x: x != null)
    |> removeAttrs cfg.lenguajes;

  entornosDeEjecucionEnUso =
    lenguajesActivosYConEntornosDeEjecucion
    |> lib.mapAttrsToList (_: lenguaje: lenguaje.entornoDeEjecucion)
    |> lib.unique
    |> (
      x:
      cfg.entornosDeEjecucion
      |> lib.mapAttrsToList (clave: entornoDeEjecucion: if !(builtins.elem clave x) then clave else null)
      |> builtins.filter (x: x != null)
    )
    |> removeAttrs cfg.entornosDeEjecucion;
in
lib.mkIf (cfg.activar && lenguajesActivosYConEntornosDeEjecucion != { }) {
  home.packages =
    entornosDeEjecucionEnUso |> lib.mapAttrsToList (_: entornoDeEjecucion: entornoDeEjecucion.paquete);

  programs.neovix.complementos."Code Runner" = {
    paquete = pkgs.vimUtils.buildVimPlugin {
      name = "code_runner";
      src = fetchGit {
        url = "https://github.com/CRAG666/code_runner.nvim";
        ref = "main";
        rev = "45dfea066a6110abcbc3cd361457ac3cbaefd68b";
      };
    };

    configuracion =
      let
        entornosDeEjecucionConfiguradosParaCadaLenguaje =
          lenguajesActivosYConEntornosDeEjecucion
          |> lib.mapAttrsToList (
            clave: lenguaje: {
              name = clave;
              value = cfg.entornosDeEjecucion.${lenguaje.entornoDeEjecucion}.configuracionDeCodeRunner;
            }
          )
          |> lib.listToAttrs;

        configuracionDelComplemento = {
          focus = true;
          filetype = entornosDeEjecucionConfiguradosParaCadaLenguaje;
        };

      in
      /* lua */ ''
        require("code_runner").setup(${lib.generators.toLua { } configuracionDelComplemento})
      '';
    lazy.teclas."<s-r>" = {
      accion = /* lua */ ''require("code_runner").run_code()'';
      descripcion = "Ejecutar código!";
    };
  };
}
