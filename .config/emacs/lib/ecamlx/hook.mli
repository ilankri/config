val find_file : (Ecaml.Hook.normal, unit) Ecaml.Hook.t
val post_self_insert : (Ecaml.Hook.normal, unit) Ecaml.Hook.t

module Function : sig
  val create :
    name:string ->
    __POS__:Position.t ->
    ?docstring:string ->
    ?should_profile:bool ->
    hook_type:('a, unit) Ecaml.Hook.Hook_type.t ->
    returns:unit Ecaml.Value.Type.t ->
    ('a -> unit) ->
    ('a, unit) Ecaml.Hook.Function.t
end
