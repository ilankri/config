module Command : sig
  val imenu : Ecaml.Command.t
end

val auto_rescan : bool Ecaml.Customization.t
