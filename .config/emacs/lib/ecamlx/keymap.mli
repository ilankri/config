module Modifier : sig
  type t = [ `Control | `Meta | `Shift | `Super ]

  val type_ : t Ecaml.Value.Type.t
end

val global_set : string -> Ecaml.Command.t -> unit
val local_set : string -> Ecaml.Command.t -> unit
val local_unset : string -> unit
