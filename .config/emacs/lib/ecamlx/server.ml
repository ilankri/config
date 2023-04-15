let start ?leave_dead ?inhibit_prompt () =
  let start =
    let open Ecaml.Funcall.Wrap in
    "server-start" <: nil_or bool @-> nil_or bool @-> return nil
  in
  start leave_dead inhibit_prompt
