type position = string * int * int * int

let position ~__POS__:(pos_fname, pos_lnum, pos_cnum, _) =
  { Lexing.pos_fname; pos_lnum; pos_cnum; pos_bol = 0 }

let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecaml.defun (Ecaml.Symbol.intern name) (position ~__POS__)
    ~docstring:(Option.value ~default:"None" docstring)
    ?define_keys ?obsoletes ?should_profile ?interactive ?disabled ?evil_config
    (Ecaml.Returns.Returns returns) f

module Custom = struct
  let load_theme ?no_confirm ?no_enable theme =
    let load_theme =
      let open Ecaml.Funcall.Wrap in
      "load-theme"
      <: Ecaml.Symbol.t @-> nil_or bool @-> nil_or bool @-> return nil
    in
    load_theme (Ecaml.Symbol.intern theme) no_confirm no_enable
end
