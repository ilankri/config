let compact =
  let type_ =
    let module Type = struct
      type t = [ `Never | `Always | `Long ]

      let all = [ `Never; `Always; `Long ]

      let sexp_of_t value =
        let atom =
          match value with `Never -> "nil" | `Always -> "t" | `Long -> "long"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "mode-line-compact" (module Type)
  in
  let open Ecaml.Customization.Wrap in
  "mode-line-compact" <: type_
