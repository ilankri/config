module Coq = struct
  let one_command_per_line =
    let open Ecaml.Customization.Wrap in
    "coq-one-command-per-line" <: bool
end

let splash_enable =
  let open Ecaml.Customization.Wrap in
  "proof-splash-enable" <: bool

let three_window_mode_policy =
  let type_ =
    let module Type = struct
      type t = [ `Smart | `Horizontal | `Hybrid | `Vertical ]

      let all = [ `Smart; `Horizontal; `Hybrid; `Vertical ]

      let sexp_of_t value =
        let atom =
          match value with
          | `Smart -> "smart"
          | `Horizontal -> "horizontal"
          | `Hybrid -> "hybrid"
          | `Vertical -> "vertical"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "proof-three-window-mode-policy" (module Type)
  in
  let open Ecaml.Customization.Wrap in
  "proof-three-window-mode-policy" <: type_
