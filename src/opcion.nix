{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.programs.neovix;
in
{
  options.programs.neovix = {
    activar = mkEnableOption "Activar neovix";
    editorPorDefecto = mkOption {
      type = types.bool;
      default = false;
      description = "Si Neovim debe ser el editor por defecto";
    };
    configuracion = mkOption {
      type = types.str;
      default = "";
      description = "Configuracion Lua de Neovim";
    };
    paquetesExtra = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Paquetes adicionales";
    };
    paquetesLuaExtra = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Paquetes adicionales de Lua";
    };
    complementos = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            activar = mkOption {
              type = types.bool;
              default = true;
              description = "Activar complemento";
            };
            paquete = mkOption {
              type = types.package;
              description = "Paquete del complemento";
            };
            complementosDependientes = mkOption {
              type = types.listOf types.package;
              default = [ ];
              description = "Complementos de los que depende el complemento";
            };
            paquetesDependientes = mkOption {
              type = types.listOf types.package;
              default = [ ];
              description = "Paquetes de los que depende el complemento";
            };
            paquetesDeLuaDependientes = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Paquetes de Lua de los que depende el complemento";
            };
            opciones = mkOption {
              type = types.nullOr (types.attrsOf types.anything);
              default = null;
              description = "Opciones del complemento";
            };
            configuracion = mkOption {
              type = types.str;
              default = "";
              description = "Configuracion Lua del complemento";
            };
            lazy = {
              activar = mkOption {
                type = types.bool;
                default = true;
                description = "Activar carga perezosa del complemento";
              };
              eventos = mkOption {
                type = types.listOf (
                  types.enum [
                    "LspAttach"
                    "VeryLazy"
                    "BufAdd"
                    "BufDelete"
                    "BufEnter"
                    "BufFilePost"
                    "BufFilePre"
                    "BufHidden"
                    "BufLeave"
                    "BufModifiedSet"
                    "BufNew"
                    "BufNewFile"
                    "BufRead"
                    "BufReadPost"
                    "BufReadCmd"
                    "BufReadPre"
                    "BufUnload"
                    "BufWinEnter"
                    "BufWinLeave"
                    "BufWipeout"
                    "BufWrite"
                    "BufWritePre"
                    "BufWriteCmd"
                    "BufWritePost"
                    "ChanInfo"
                    "ChanOpen"
                    "CmdUndefined"
                    "CmdlineChanged"
                    "CmdlineEnter"
                    "CmdlineLeave"
                    "CmdwinEnter"
                    "CmdwinLeave"
                    "ColorScheme"
                    "ColorSchemePre"
                    "CompleteChanged"
                    "CompleteDonePre"
                    "CompleteDone"
                    "CursorHold"
                    "CursorHoldI"
                    "CursorMoved"
                    "CursorMovedI"
                    "DiffUpdated"
                    "DirChanged"
                    "DirChangedPre"
                    "ExitPre"
                    "FileAppendCmd"
                    "FileAppendPost"
                    "FileAppendPre"
                    "FileChangedRO"
                    "FileChangedShell"
                    "FileChangedShellPost"
                    "FileReadCmd"
                    "FileReadPost"
                    "FileReadPre"
                    "FileType"
                    "FileWriteCmd"
                    "FileWritePost"
                    "FileWritePre"
                    "FilterReadPost"
                    "FilterReadPre"
                    "FilterWritePost"
                    "FilterWritePre"
                    "FocusGained"
                    "FocusLost"
                    "FuncUndefined"
                    "UIEnter"
                    "UILeave"
                    "InsertChange"
                    "InsertCharPre"
                    "InsertEnter"
                    "InsertLeavePre"
                    "InsertLeave"
                    "MenuPopup"
                    "ModeChanged"
                    "OptionSet"
                    "QuickFixCmdPre"
                    "QuickFixCmdPost"
                    "QuitPre"
                    "RemoteReply"
                    "SearchWrapped"
                    "RecordingEnter"
                    "RecordingLeave"
                    "SessionLoadPost"
                    "ShellCmdPost"
                    "Signal"
                    "ShellFilterPost"
                    "SourcePre"
                    "SourcePost"
                    "SourceCmd"
                    "SpellFileMissing"
                    "StdinReadPost"
                    "StdinReadPre"
                    "SwapExists"
                    "Syntax"
                    "TabEnter"
                    "TabLeave"
                    "TabNew"
                    "TabNewEntered"
                    "TabClosed"
                    "TermOpen"
                    "TermEnter"
                    "TermLeave"
                    "TermClose"
                    "TermResponse"
                    "TextChanged"
                    "TextChangedI"
                    "TextChangedP"
                    "TextChangedT"
                    "TextYankPost"
                    "User"
                    "UserGettingBored"
                    "VimEnter"
                    "VimLeave"
                    "VimLeavePre"
                    "VimResized"
                    "VimResume"
                    "VimSuspend"
                    "WinClosed"
                    "WinEnter"
                    "WinLeave"
                    "WinNew"
                    "WinScrolled"
                    "WinResized"
                  ]
                );
                default = [ ];
                description = "Eventos que activaran el complemento";
              };
              comandos = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Comandos que activaran el complemento";
              };
              tiposDeArchivo = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Tipos de archivo que activaran el complemento";
              };
              teclas = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      accion = mkOption {
                        type = types.str;
                        default = "";
                        description = "Código Lua a ejecutar";
                      };
                      comando = mkOption {
                        type = types.str;
                        default = "";
                        description = "Comando a ejecutar";
                      };
                      modos = mkOption {
                        type = types.listOf (
                          types.enum [
                            "i"
                            "n"
                            "v"
                            "x"
                            "s"
                            "o"
                            "c"
                            "t"
                            ""
                          ]
                        );
                        default = [ "n" ];
                        description = "Modos en los que se ejecutará el atajo";
                      };
                      descripcion = mkOption {
                        type = types.str;
                        default = "";
                        description = "Descripción del atajo de teclado";
                      };
                    };
                  }
                );
                default = { };
                description = "Atajos de teclado del complemento";
              };
            };
          };
        }
      );
      default = { };
      description = "Complementos de Neovim";
    };
    formateadores = mkOption {
      type = types.nullOr (
        types.attrsOf (
          types.submodule {
            options = {
              paquete = mkOption {
                type = types.nullOr types.package;
                default = null;
                description = "Paquete del formateador";
              };
              configuracion = mkOption {
                type = types.nullOr (types.attrsOf types.anything);
                default = null;
                description = "Configuración del formateador (https://github.com/stevearc/conform.nvim)";
              };
            };
          }
        )
      );
      default = null;
      description = "Configuración de formateadores";
    };
    lspconfig = {
      complementosDependientes = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Complementos dependientes";
      };
      configuracionComun = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Configuración común de LSP";
      };
      configuraciones = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              paquete = mkOption {
                type = with types; nullOr package;
                default = null;
                description = "Paquete del LSP del lenguaje";
              };
              configuracion = mkOption {
                type = with types; nullOr (attrsOf anything);
                default = null;
                description = "Configuración del LSP del lenguaje";
              };
            };
          }
        );
        default = { };
        description = "Configuración del LSPs";
      };
    };
    entornosDeEjecucion = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            paquete = mkOption {
              type = types.package;
              description = "Paquete del entorno de ejecución";
            };
            configuracionDeCodeRunner = mkOption {
              type = types.str;
              default = "";
              description = "Configuración de CRAG666/code_runner.nvim";
            };
          };
        }
      );
      default = { };
      description = "Configuración de entornos de ejecución";
    };
    lenguajes = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            activar = mkOption {
              type = types.bool;
              default = true;
              description = "Activar la configuración del lenguaje";
            };
            gramaticas = mkOption {
              type = with types; nullOr (listOf package);
              default = null;
              description = "Paquetes de la gramática de Treesitter";
            };
            formateadores = mkOption {
              type = types.nullOr (types.listOf (types.enum (builtins.attrNames cfg.formateadores)));
              default = null;
              description = "Formateadores activos para este lenguaje";
            };
            lsps = mkOption {
              type = with types; nullOr (listOf (enum (builtins.attrNames cfg.lspconfig.configuraciones)));
              default = null;
              description = "LSPs activos para este lenguaje";
            };
            entornoDeEjecucion = mkOption {
              type = with types; nullOr (enum (builtins.attrNames cfg.entornosDeEjecucion));
              default = null;
              description = "Entorno de ejecución para este lenguaje";
            };
          };
        }
      );
      default = { };
      description = "Configuración de lenguajes (gramaticas, LSP, formateadores)";
    };
  };

}
