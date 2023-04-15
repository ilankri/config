val common_hook : Ecaml.Hook.normal Ecaml.Hook.t
val initialization_hook : Ecaml.Hook.normal Ecaml.Hook.t

module Default_style : sig
  type t = {
    other : string option;
    major_modes : (Ecaml.Major_mode.t * string) list;
  }
end

val default_style : Default_style.t Ecaml.Customization.t
