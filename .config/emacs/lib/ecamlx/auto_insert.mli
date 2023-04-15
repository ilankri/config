val define :
  ?after:bool ->
  ?description:string ->
  [ `Regexp of Ecaml.Regexp.t | `Major_mode of Ecaml.Major_mode.t ] ->
  [ `File of string | `Function of Ecaml.Function.t ] ->
  unit

val directory : string Ecaml.Customization.t
