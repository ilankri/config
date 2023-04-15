let compilation_filter =
  let open Ecaml.Funcall.Wrap in
  "ansi-color-compilation-filter" <: nullary @-> return nil
