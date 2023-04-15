module Command : sig
  val message : Ecaml.Command.t
  val comments_and_strings : Ecaml.Command.t
  val change_dictionary : Ecaml.Command.t
  val ispell : Ecaml.Command.t
end

val program_name : string Ecaml.Customization.t
val change_dictionary : ?globally:bool -> string -> unit
val dictionary : string option Ecaml.Customization.t
val local_dictionary : string option Ecaml.Customization.t
val ispell : unit -> unit
