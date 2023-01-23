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
  val set_buffer_local : 'a Ecaml.Customization.t -> 'a -> unit
end

module Hook : sig
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
  module Csv : Ecaml.Major_mode.S_with_lazy_keymap
end

module Custom : sig
  val load_theme : ?no_confirm:bool -> ?no_enable:bool -> string -> unit
end

module Server : sig
  val start : ?leave_dead:bool -> ?inhibit_prompt:bool -> unit -> unit
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
