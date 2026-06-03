{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.neovix;
in
{

  config = lib.mkIf cfg.activar {
    programs.neovim =
      let
        complementosActivados =
          cfg.complementos
          |> lib.mapAttrsToList (clave: complemento: if !complemento.activar then clave else null)
          |> builtins.filter (x: x != null)
          |> removeAttrs cfg.complementos;
      in
      {
        enable = true;
        defaultEditor = cfg.editorPorDefecto;
        extraLuaConfig = cfg.configuracion;
        extraPackages =
          complementosActivados
          |> lib.mapAttrsToList (_: complemento: complemento.dependenciasDeSistema)
          |> lib.flatten
          |> (x: cfg.paquetesExtra ++ x);
        extraLuaPackages =
          let
            paquetesLuaExtra =
              complementosActivados
              |> lib.mapAttrsToList (_: complemento: complemento.dependenciasDeLua)
              |> lib.lists.flatten;
          in
          ps: paquetesLuaExtra |> map (nombre: ps.${nombre});
        plugins = [
          {
            plugin = pkgs.vimPlugins.lazy-nvim;
            type = "lua";
            config =
              let

                crearPropiedadDeLista = clave: lista: if lista == [ ] then { } else { ${clave} = lista; };

                formatearDependencias =
                  dependencias:
                  dependencias
                  |> map (dependencia: {
                    dir = "${dependencia}";
                  })
                  |> crearPropiedadDeLista "dependencies";

                formatearEventos = eventos: crearPropiedadDeLista "event" eventos;

                formatearTiposDeArchivos = tiposDeArchivo: crearPropiedadDeLista "ft" tiposDeArchivo;

                formatearComandos = comandos: crearPropiedadDeLista "cmd" comandos;

                formatearConfiguracion =
                  configuracion:
                  if configuracion == "" then
                    { }
                  else
                    {
                      config = lib.mkLuaInline /* lua */ ''
                        function()
                          ${configuracion}
                        end
                      '';
                    };

                accionOComando =
                  tecla: with tecla; if accion != "" then /* lua */ "function() ${accion} end" else ''"${comando}"'';

                formatearTeclas =
                  teclas:
                  if teclas == { } then
                    { }
                  else
                    {
                      keys =
                        teclas
                        |> lib.mapAttrsToList (
                          clave: tecla:
                          lib.mkLuaInline /* lua */ ''
                            {
                              "${clave}",
                              ${accionOComando tecla},
                              mode = ${lib.generators.toLua { } tecla.modos},
                              desc = "${tecla.descripcion}"
                            } ''
                        );
                    };

                complementosFormateadosParaLazy =
                  complementosActivados
                  |> lib.mapAttrsToList (
                    clave: complemento:
                    with complemento;
                    {
                      dir = "${complemento.paquete}";
                      name = clave;
                      lazy = lazy.activar;
                    }
                    // formatearConfiguracion complemento.configuracion
                    // formatearDependencias dependencias
                    // formatearTiposDeArchivos lazy.tiposDeArchivo
                    // formatearEventos lazy.eventos
                    // formatearComandos lazy.comandos
                    // formatearTeclas lazy.teclas
                  );

                configuracion = {
                  spec = complementosFormateadosParaLazy;
                  checker.enabled = false;
                  pkg.enabled = false;
                  rocks.enabled = false;
                  install.missing = false;
                  change_detection.enabled = false;
                };
              in
              /* lua */ ''
                require("lazy").setup(${lib.generators.toLua { } configuracion})
              '';
          }
        ];
      };
  };
}
