val initial_buffer_choice :
  [ `Scratch | `File of string | `Function of Ecaml.Function.t ] option
  Ecaml.Customization.t

val inhibit_startup_screen : bool Ecaml.Customization.t
