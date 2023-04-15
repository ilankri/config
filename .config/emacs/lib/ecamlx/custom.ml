let load_theme ?no_confirm ?no_enable theme =
  let load_theme =
    let open Ecaml.Funcall.Wrap in
    "load-theme"
    <: Ecaml.Symbol.t @-> nil_or bool @-> nil_or bool @-> return nil
  in
  load_theme (Ecaml.Symbol.intern theme) no_confirm no_enable

let file =
  let open Ecaml.Customization.Wrap in
  "custom-file" <: nil_or string
