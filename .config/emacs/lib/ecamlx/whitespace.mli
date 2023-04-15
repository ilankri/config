module Command : sig
  val cleanup : Ecaml.Command.t
end

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

module Global_modes : sig
  type t =
    | All of { except : Ecaml.Major_mode.t list }
    | Only of Ecaml.Major_mode.t list
end

val global_modes : Global_modes.t Ecaml.Customization.t
