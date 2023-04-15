module Indent = struct
  let default_run_on_strategy =
    let type_ =
      let module Type = struct
        type t = [ `Eager | `Operators | `Reluctant ]

        let all = [ `Eager; `Operators; `Reluctant ]

        let sexp_of_t value =
          let atom =
            match value with
            | `Eager -> "scala-indent:eager-strategy"
            | `Operators -> "scala-indent:operator-strategy"
            | `Reluctant -> "scala-indent:reluctant-strategy"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "require-final-newline" (module Type)
    in
    let open Ecaml.Customization.Wrap in
    "scala-indent:default-run-on-strategy" <: type_
end
