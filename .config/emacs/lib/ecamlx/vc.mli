val follow_symlinks :
  [ `Ask | `Visit_link_and_warn | `Follow_link ] Ecaml.Customization.t

val command_messages :
  [ `No | `Log_and_display | `Log_only ] Ecaml.Customization.t

val root_dir : unit -> string option

module Git : sig
  val feature : Ecaml.Feature.t
  val grep : ?files:string -> ?dir:string -> Ecaml.Regexp.t -> unit
end
