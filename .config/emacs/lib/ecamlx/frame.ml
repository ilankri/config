let toggle_fullscreen ?frame () =
  let toggle_fullscreen =
    let open Ecaml.Funcall.Wrap in
    "toggle-frame-fullscreen" <: nil_or Ecaml.Frame.type_ @-> return nil
  in
  toggle_fullscreen frame
