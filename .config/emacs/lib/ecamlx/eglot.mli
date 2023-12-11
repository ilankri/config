module Command : sig
  val code_actions : unit -> Ecaml.Command.t
  val rename : unit -> Ecaml.Command.t
end

val stay_out_of :
  [ `Symbol of Ecaml.Symbol.t | `Regexp of Ecaml.Regexp.t ] list Ecaml.Var.t

val autoshutdown : bool Ecaml.Customization.t

val ignored_server_capabilities :
  [ `Hover_provider
  | `Completion_provider
  | `Signature_help_provider
  | `Definition_provider
  | `Type_definition_provider
  | `Implementation_provider
  | `Declaration_provider
  | `References_provider
  | `Document_highlight_provider
  | `Document_symbol_provider
  | `Workspace_symbol_provider
  | `Code_action_provider
  | `Code_lens_provider
  | `Document_formatting_provider
  | `Document_range_formatting_provider
  | `Document_on_type_formatting_provider
  | `Rename_provider
  | `Document_link_provider
  | `Color_provider
  | `Folding_range_provider
  | `Execute_command_provider ]
  list
  Ecaml.Customization.t

module Language : sig
  type t = { major_mode : Ecaml.Major_mode.t; id : string option }

  val make : ?id:string -> Ecaml.Major_mode.t -> t

  module Server : sig
    type t =
      | Program of {
          name : string;
          args : string list;
          initialization_options :
            [ `List of Ecaml.Value.t list | `Function of Ecaml.Function.t ]
            option;
        }
      | Program_with_auto_port of {
          name : string;
          args_before_auto_port : string list;
          args_after_auto_port : string list;
        }
      | Host of { name : string; port : int; tcp_args : string list }
      | Class of { name : Ecaml.Symbol.t; init_args : Ecaml.Value.t list }

    val make_program :
      ?args:string list ->
      ?initialization_options:
        [ `List of Ecaml.Value.t list | `Function of Ecaml.Function.t ] ->
      string ->
      t
  end
end

val server_programs :
  (Language.t list
  * [ `Language_server of Language.Server.t | `Function of Ecaml.Function.t ])
  list
  Ecaml.Var.t

val connect_timeout : int option Ecaml.Customization.t
val ensure : unit -> unit
val managed_p : unit -> bool
val format_buffer : unit -> unit
