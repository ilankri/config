val default_keybindings :
  ?modifiers:[ `List of Keymap.Modifier.t list | `None ] -> unit -> unit

val delete_default_keybindings :
  ?prefix:string ->
  ?modifiers:[ `List of Keymap.Modifier.t list | `None ] ->
  unit ->
  unit

val display_default_keybindings :
  ?modifiers:[ `List of Keymap.Modifier.t list | `None ] -> unit -> unit

val swap_states_default_keybindings :
  ?modifiers:[ `List of Keymap.Modifier.t list | `None ] -> unit -> unit
