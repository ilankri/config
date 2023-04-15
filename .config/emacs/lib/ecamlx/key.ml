let global_set =
  let open Ecaml.Funcall.Wrap in
  "global-set-key"
  <: Ecaml.Key_sequence.type_ @-> Ecaml.Command.type_ @-> return nil

let local_set =
  let open Ecaml.Funcall.Wrap in
  "local-set-key"
  <: Ecaml.Key_sequence.type_ @-> Ecaml.Command.type_ @-> return nil

let local_unset =
  let open Ecaml.Funcall.Wrap in
  "local-unset-key" <: Ecaml.Key_sequence.type_ @-> return nil
