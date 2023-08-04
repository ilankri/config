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

let completion_auto_help =
  let lazy_ = Ecaml.Value.intern "lazy" in
  let visible = Ecaml.Value.intern "visible" in
  let always = Ecaml.Value.intern "always" in
  let type_ =
    let to_ value =
      if Ecaml.Value.eq value Ecaml.Value.t then `Only_when_cannot_complete
      else if Ecaml.Value.is_nil value then `Never
      else if Ecaml.Value.eq value lazy_ then `Lazy
      else if Ecaml.Value.eq value visible then `Visible
      else if Ecaml.Value.eq value always then `Always
      else assert false
    in
    let from = function
      | `Only_when_cannot_complete -> Ecaml.Value.t
      | `Never -> Ecaml.Value.nil
      | `Lazy -> lazy_
      | `Visible -> visible
      | `Always -> always
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "completion-auto-help") to_sexp
      to_ from
  in
  let open Ecaml.Customization.Wrap in
  "completion-auto-help" <: type_

let completion_auto_select =
  let second_tab = Ecaml.Value.intern "second-tab" in
  let type_ =
    let to_ value =
      if Ecaml.Value.eq value Ecaml.Value.t then `On_first_tab
      else if Ecaml.Value.is_nil value then `Never
      else if Ecaml.Value.eq value second_tab then `On_second_tab
      else assert false
    in
    let from = function
      | `On_first_tab -> Ecaml.Value.t
      | `Never -> Ecaml.Value.nil
      | `On_second_tab -> second_tab
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "completion-auto-select")
      to_sexp to_ from
  in
  let open Ecaml.Customization.Wrap in
  "completion-auto-select" <: type_
