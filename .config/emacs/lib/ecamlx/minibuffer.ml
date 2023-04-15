let completions_format =
  let type_ =
    let module Type = struct
      type t = [ `Horizontal | `Vertical | `One_column ]

      let all = [ `Horizontal; `Vertical; `One_column ]

      let sexp_of_t value =
        let atom =
          match value with
          | `Horizontal -> "horizontal"
          | `Vertical -> "vertical"
          | `One_column -> "one-column"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "completions-format" (module Type)
  in
  let open Ecaml.Customization.Wrap in
  "completions-format" <: type_

let enable_recursive_minibuffers =
  let open Ecaml.Customization.Wrap in
  "enable-recursive-minibuffers" <: bool
