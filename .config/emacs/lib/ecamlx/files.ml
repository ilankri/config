let view_read_only =
  let open Ecaml.Customization.Wrap in
  "view-read-only" <: bool

let auto_mode_case_fold =
  let open Ecaml.Customization.Wrap in
  "auto-mode-case-fold" <: bool

let require_final_newline =
  let type_ =
    let module Type = struct
      type t = [ `Visit | `Save | `Visit_save | `Never | `Ask ]

      let all = [ `Visit; `Save; `Visit_save; `Never; `Ask ]

      let sexp_of_t value =
        let atom =
          match value with
          | `Visit -> "visit"
          | `Save -> "t"
          | `Visit_save -> "visit-save"
          | `Never -> "nil"
          | `Ask -> "ask"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "require-final-newline" (module Type)
  in
  let open Ecaml.Customization.Wrap in
  "require-final-newline" <: type_
