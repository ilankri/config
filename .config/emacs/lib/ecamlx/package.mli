val feature : Ecaml.Feature.t
val archives : (string * string) list Ecaml.Customization.t
val selected_packages : Ecaml.Symbol.t list Ecaml.Customization.t
val initialize : ?no_activate:bool -> unit -> unit
val install_selected_packages : ?no_confirm:bool -> unit -> unit
val upgrade_all : ?query:bool -> unit -> unit
val autoremove : unit -> unit

module Vc : sig
  module Package_specification : sig
    type t = {
      url : string;
      branch : string option;
      lisp_dir : string option;
      main_file : string option;
      doc : string option;
      vc_backend : Ecaml.Symbol.t option;
    }

    val make :
      ?branch:string ->
      ?lisp_dir:string ->
      ?main_file:string ->
      ?doc:string ->
      ?vc_backend:Ecaml.Symbol.t ->
      string ->
      t
  end

  val selected_packages :
    (Ecaml.Symbol.t
    * [ `Version of string | `Package_specification of Package_specification.t ]
      option)
    list
    Ecaml.Customization.t

  val install_selected_packages : unit -> unit
end
