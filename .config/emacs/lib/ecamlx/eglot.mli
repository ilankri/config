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

val ensure : unit -> unit
val managed_p : unit -> bool
val format_buffer : unit -> unit
