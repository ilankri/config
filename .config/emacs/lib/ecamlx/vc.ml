let follow_symlinks =
  let type_ =
    let module Type = struct
      type t = [ `Ask | `Visit_link_and_warn | `Follow_link ]

      let all = [ `Ask; `Visit_link_and_warn; `Follow_link ]

      let sexp_of_t value =
        let atom =
          match value with
          | `Ask -> "ask"
          | `Visit_link_and_warn -> "nil"
          | `Follow_link -> "t"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "vc-follow-symlinks" (module Type)
  in
  let open Ecaml.Customization.Wrap in
  "vc-follow-symlinks" <: type_

let command_messages =
  let type_ =
    let module Type = struct
      type t = [ `No | `Log_and_display | `Log_only ]

      let all = [ `No; `Log_and_display; `Log_only ]

      let sexp_of_t value =
        let atom =
          match value with
          | `No -> "nil"
          | `Log_and_display -> "t"
          | `Log_only -> "log"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "vc-command-messages" (module Type)
  in
  let open Ecaml.Customization.Wrap in
  "vc-command-messages" <: type_

let root_dir =
  let open Ecaml.Funcall.Wrap in
  "vc-root-dir" <: nullary @-> return (nil_or string)

module Git = struct
  let feature = Ecaml.Symbol.intern "vc-git"

  let grep ?files ?dir regexp =
    let grep =
      let open Ecaml.Funcall.Wrap in
      "vc-git-grep"
      <: Ecaml.Regexp.t @-> nil_or string @-> nil_or string @-> return nil
    in
    grep regexp files dir
end
