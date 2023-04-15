module Coq : sig
  val one_command_per_line : bool Ecaml.Customization.t
end

val splash_enable : bool Ecaml.Customization.t

val three_window_mode_policy :
  [ `Smart | `Horizontal | `Hybrid | `Vertical ] Ecaml.Customization.t
