type position = string * int * int * int

val defun :
  name:string ->
  __POS__:position ->
  ?docstring:string ->
  ?define_keys:(Ecaml.Keymap.t * string) list ->
  ?obsoletes:Ecaml.Defun.Obsoletes.t ->
  ?should_profile:bool ->
  ?interactive:Ecaml.Defun.Interactive.t ->
  ?disabled:bool ->
  ?evil_config:Ecaml.Evil.Config.t ->
  returns:'a Ecaml.Value.Type.t ->
  'a Ecaml.Defun.t ->
  unit

module Current_buffer : sig
  val inhibit_read_only : bool Ecaml.Var.t
  val set_buffer_local : 'a Ecaml.Var.t -> 'a -> unit
  val set_customization_buffer_local : 'a Ecaml.Customization.t -> 'a -> unit
end

module Hook : sig
  val find_file : Ecaml.Hook.normal Ecaml.Hook.t

  module Function : sig
    val create :
      name:string ->
      __POS__:position ->
      ?docstring:string ->
      ?should_profile:bool ->
      hook_type:'a Ecaml.Hook.Hook_type.t ->
      returns:unit Ecaml.Value.Type.t ->
      ('a -> unit) ->
      'a Ecaml.Hook.Function.t
  end
end

module Major_mode : sig
  module Conf : Ecaml.Major_mode.S_with_lazy_keymap
  module Csv : Ecaml.Major_mode.S_with_lazy_keymap
  module Diff : Ecaml.Major_mode.S_with_lazy_keymap
  module Markdown : Ecaml.Major_mode.S_with_lazy_keymap
end

module Minor_mode : sig
  val smerge : Ecaml.Minor_mode.t
end

module Custom : sig
  val load_theme : ?no_confirm:bool -> ?no_enable:bool -> string -> unit
end

module Files : sig
  val view_read_only : bool Ecaml.Customization.t
end

module Indent : sig
  val tabs_mode : bool Ecaml.Customization.t
end

module Markdown_mode : sig
  val cleanup_list_numbers : unit -> unit
  val command : string Ecaml.Customization.t
  val asymmetric_header : bool Ecaml.Customization.t
  val fontify_code_blocks_natively : bool Ecaml.Customization.t
end

module Server : sig
  val start : ?leave_dead:bool -> ?inhibit_prompt:bool -> unit -> unit
end

module Smerge_mode : sig
  val feature : Ecaml.Symbol.t
  val begin_re : Ecaml.Regexp.t Ecaml.Var.t
end

module Whitespace : sig
  module Style : sig
    type indentation_char = Tab | Space

    type t =
      | Face
      | Trailing
      | Tabs
      | Spaces
      | Lines
      | Lines_tail
      | Newline
      | Missing_newline_at_eof
      | Empty
      | Indentation of indentation_char option
      | Big_indent
      | Space_after_tab of indentation_char option
      | Space_before_tab of indentation_char option
      | Space_mark
      | Tab_mark
      | Newline_mark
  end

  val style : Style.t list Ecaml.Customization.t

  module Action : sig
    type t =
      | Cleanup
      | Report_on_bogus
      | Auto_cleanup
      | Abort_on_bogus
      | Warn_if_read_only
  end

  val action : Action.t list Ecaml.Customization.t
end
