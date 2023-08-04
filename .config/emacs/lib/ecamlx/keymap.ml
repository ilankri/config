let global_set =
  let open Ecaml.Funcall.Wrap in
  "keymap-global-set" <: string @-> Ecaml.Command.type_ @-> return nil

let local_set =
  let open Ecaml.Funcall.Wrap in
  "keymap-local-set" <: string @-> Ecaml.Command.type_ @-> return nil

let local_unset =
  let open Ecaml.Funcall.Wrap in
  "keymap-local-unset" <: string @-> return nil
