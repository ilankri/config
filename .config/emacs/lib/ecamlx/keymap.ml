module Modifier = struct
  type t = [ `Control | `Meta | `Shift | `Super ]

  let type_ =
    let module Type = struct
      type nonrec t = t

      let all = [ `Control; `Meta; `Shift; `Super ]

      let sexp_of_t value =
        let atom =
          match value with
          | `Control -> "control"
          | `Meta -> "meta"
          | `Shift -> "shift"
          | `Super -> "super"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "keymap-modifier" (module Type)
end

let global_set =
  let open Ecaml.Funcall.Wrap in
  "keymap-global-set" <: string @-> Ecaml.Command.type_ @-> return nil

let local_set =
  let open Ecaml.Funcall.Wrap in
  "keymap-local-set" <: string @-> Ecaml.Command.type_ @-> return nil

let local_unset =
  let open Ecaml.Funcall.Wrap in
  "keymap-local-unset" <: string @-> return nil
