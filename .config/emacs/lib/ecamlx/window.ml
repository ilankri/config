let set_buffer_start_and_point ?start ?point ~buffer window =
  let set_buffer_start_and_point =
    let open Ecaml.Funcall.Wrap in
    "set-window-buffer-start-and-point"
    <: Ecaml.Window.type_ @-> Ecaml.Buffer.type_
       @-> nil_or Ecaml.Position.type_
       @-> nil_or Ecaml.Position.type_
       @-> return nil
  in
  set_buffer_start_and_point window buffer start point
