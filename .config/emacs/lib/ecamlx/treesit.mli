val feature : Ecaml.Feature.t
val ready_p : ?quiet:[ `Yes | `No | `Message ] -> Ecaml.Symbol.t -> bool

module Language_source : sig
  type t = {
    url : string;
    revision : string option;
    source_dir : string option;
    cc : string option;
    c_plus_plus : string option;
  }

  val make :
    ?revision:string ->
    ?source_dir:string ->
    ?cc:string ->
    ?c_plus_plus:string ->
    string ->
    t
end

val language_source_alist :
  (Ecaml.Symbol.t * Language_source.t) list Ecaml.Var.t

val install_language_grammar : Ecaml.Symbol.t -> unit
