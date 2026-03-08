module Modifiers = struct
  let type_ =
    let none = Ecaml.Value.intern "none" in
    let to_ value =
      if Ecaml.Value.eq value none then `None
      else
        `List
          (Ecaml.Value.to_list_exn value
             ~f:(Ecaml.Value.Type.of_value_exn Keymap.Modifier.type_))
    in
    let from = function
      | `None -> none
      | `List modifiers ->
          Ecaml.Value.list
          @@ List.map
               (Ecaml.Value.Type.to_value Keymap.Modifier.type_)
               modifiers
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "windmove-modifiers") to_sexp
      to_ from
end

let default_keybindings ?modifiers () =
  let default_keybindings =
    let open Ecaml.Funcall.Wrap in
    "windmove-default-keybindings" <: nil_or Modifiers.type_ @-> return nil
  in
  default_keybindings modifiers

let delete_default_keybindings ?prefix ?modifiers () =
  let delete_default_keybindings =
    let open Ecaml.Funcall.Wrap in
    "windmove-delete-default-keybindings"
    <: nil_or string @-> nil_or Modifiers.type_ @-> return nil
  in
  delete_default_keybindings prefix modifiers

let display_default_keybindings ?modifiers () =
  let display_default_keybindings =
    let open Ecaml.Funcall.Wrap in
    "windmove-display-default-keybindings"
    <: nil_or Modifiers.type_ @-> return nil
  in
  display_default_keybindings modifiers

let swap_states_default_keybindings ?modifiers () =
  let swap_states_default_keybindings =
    let open Ecaml.Funcall.Wrap in
    "windmove-swap-states-default-keybindings"
    <: nil_or Modifiers.type_ @-> return nil
  in
  swap_states_default_keybindings modifiers
