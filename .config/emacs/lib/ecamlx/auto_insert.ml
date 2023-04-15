let define ?after ?description condition action =
  let condition_type =
    let to_ value =
      if Ecaml.Value.is_symbol value then
        `Major_mode
          (Ecaml.Major_mode.find_or_wrap_existing
             (Position.to_lexing_position ~__POS__)
             (Ecaml.Symbol.of_value_exn value))
      else `Regexp (Ecaml.Regexp.of_value_exn value)
    in
    let from = function
      | `Major_mode m -> m |> Ecaml.Major_mode.symbol |> Ecaml.Symbol.to_value
      | `Regexp r -> Ecaml.Regexp.to_value r
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "define-auto-insert-condition")
      to_sexp to_ from
  in
  let define condition =
    let action =
      let to_ value =
        if Ecaml.Value.is_function value then
          `Function (Ecaml.Function.of_value_exn value)
        else `File (Ecaml.Value.to_utf8_bytes_exn value)
      in
      let from = function
        | `Function f -> Ecaml.Function.to_value f
        | `File f -> Ecaml.Value.of_utf8_bytes f
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "define-auto-insert-action")
        to_sexp to_ from
    in
    let open Ecaml.Funcall.Wrap in
    "define-auto-insert" <: condition @-> action @-> nil_or bool @-> return nil
  in
  match description with
  | None -> (define condition_type) condition action after
  | Some description ->
      let open Ecaml.Funcall.Wrap in
      (define (tuple condition_type string))
        (condition, description) action after

let directory =
  let open Ecaml.Customization.Wrap in
  "auto-insert-directory" <: string
