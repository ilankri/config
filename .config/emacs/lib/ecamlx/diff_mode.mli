module Refine : sig
  type t = Font_lock | Navigation
end

val refine : Refine.t option Ecaml.Customization.t
val default_read_only : bool Ecaml.Customization.t
