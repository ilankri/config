module Submode : sig
  type t

  val global_stickyfunc : t
end

val default_submodes : Submode.t list Ecaml.Customization.t
