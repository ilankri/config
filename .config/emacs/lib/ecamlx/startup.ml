let initial_buffer_choice =
  let type_ =
    let to_ value =
      if Ecaml.Value.eq value Ecaml.Value.t then `Scratch
      else if Ecaml.Value.is_string value then
        `File (Ecaml.Value.to_utf8_bytes_exn value)
      else `Function (Ecaml.Function.of_value_exn value)
    in
    let from = function
      | `Scratch -> Ecaml.Value.t
      | `File s -> Ecaml.Value.of_utf8_bytes s
      | `Function f -> Ecaml.Function.to_value f
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "initial-buffer-choice") to_sexp
      to_ from
  in
  let open Ecaml.Customization.Wrap in
  "initial-buffer-choice" <: nil_or type_

let inhibit_startup_screen =
  let open Ecaml.Customization.Wrap in
  "inhibit-startup-screen" <: bool
