module Refine = struct
  type t = Font_lock | Navigation

  let type_ =
    let module Type = struct
      type nonrec t = t

      let all = [ Font_lock; Navigation ]

      let sexp_of_t value =
        let atom =
          match value with
          | Font_lock -> "font-lock"
          | Navigation -> "navigation"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "diff-refine" (module Type)
end

let refine =
  let open Ecaml.Customization.Wrap in
  "diff-refine" <: nil_or Refine.type_

let default_read_only =
  let open Ecaml.Customization.Wrap in
  "diff-default-read-only" <: bool
