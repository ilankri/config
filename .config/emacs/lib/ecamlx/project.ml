let compile =
  let open Ecaml.Funcall.Wrap in
  "project-compile" <: nullary @-> return nil
