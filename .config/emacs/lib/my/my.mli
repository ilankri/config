val init_package_archives : unit -> unit

val hook_defun :
  ?name:string ->
  __POS__:Position.t ->
  ?docstring:string ->
  ?should_profile:bool ->
  hook_type:'a Ecaml.Hook.Hook_type.t ->
  returns:unit Ecaml.Value.Type.t ->
  ('a -> unit) ->
  'a Ecaml.Hook.Function.t

module Command : sig
  val ispell_en : unit -> Ecaml.Command.t
  val ispell_fr : unit -> Ecaml.Command.t
  val indent_buffer : unit -> Ecaml.Command.t
  val git_grep : unit -> Ecaml.Command.t
  val transpose_windows : unit -> Ecaml.Command.t
  val ansi_term : unit -> Ecaml.Command.t
end
