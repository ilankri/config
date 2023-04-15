val feature : Ecaml.Feature.t
val archives : (string * string) list Ecaml.Customization.t
val refresh_contents : ?async:bool -> unit -> unit
val selected_packages : Ecaml.Symbol.t list Ecaml.Customization.t
val initialize : ?no_activate:bool -> unit -> unit
val install_selected_packages : ?no_confirm:bool -> unit -> unit
