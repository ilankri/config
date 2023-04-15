let buffer_maximum_size =
  let open Ecaml.Customization.Wrap in
  "term-buffer-maximum-size" <: int

let ansi_term ?new_buffer_name program =
  let ansi_term =
    let open Ecaml.Funcall.Wrap in
    "ansi-term" <: string @-> nil_or string @-> return Ecaml.Buffer.type_
  in
  ansi_term program new_buffer_name
