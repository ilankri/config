let context_when_offscreen =
  let overlay = Ecaml.Value.intern "overlay" in
  let child_frame = Ecaml.Value.intern "child-frame" in
  let type_ =
    let to_ value =
      if Ecaml.Value.eq value Ecaml.Value.t then `Echo_area
      else if Ecaml.Value.is_nil value then `Off
      else if Ecaml.Value.eq value overlay then `Overlay
      else if Ecaml.Value.eq value child_frame then `Child_frame
      else assert false
    in
    let from = function
      | `Echo_area -> Ecaml.Value.t
      | `Off -> Ecaml.Value.nil
      | `Overlay -> overlay
      | `Child_frame -> child_frame
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create
      (Sexplib0.Sexp.Atom "show-paren-context-when-offscreen") to_sexp to_ from
  in
  let open Ecaml.Customization.Wrap in
  "show-paren-context-when-offscreen" <: type_
