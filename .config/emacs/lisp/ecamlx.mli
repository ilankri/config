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

val global_set_key : Ecaml.Key_sequence.t -> Ecaml.Command.t -> unit
val local_set_key : Ecaml.Key_sequence.t -> Ecaml.Command.t -> unit
val mode_line_compact : [ `Never | `Always | `Long ] Ecaml.Customization.t
val track_eol : bool Ecaml.Customization.t

module Command : sig
  val blink_matching_open : Ecaml.Command.t
  val switch_to_completions : Ecaml.Command.t
end

module Current_buffer : sig
  val fill_column : int Ecaml.Customization.t
  val inhibit_read_only : bool Ecaml.Var.t
  val set_buffer_local : 'a Ecaml.Var.t -> 'a -> unit
  val set_customization_buffer_local : 'a Ecaml.Customization.t -> 'a -> unit
  val scroll_up_aggressively : float option Ecaml.Customization.t
  val scroll_down_aggressively : float option Ecaml.Customization.t
end

module Customization : sig
  val set_value : 'a Ecaml.Customization.t -> 'a -> unit
end

module Comment : sig
  val multi_line : bool Ecaml.Customization.t
end

module Fill : sig
  val nobreak_predicate : Ecaml.Function.t list Ecaml.Customization.t
  val french_nobreak_p : Ecaml.Function.t
end

module Frame : sig
  val toggle_fullscreen : ?frame:Ecaml.Frame.t -> unit -> unit
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
  module Archive : Ecaml.Major_mode.S_with_lazy_keymap
  module Conf : Ecaml.Major_mode.S_with_lazy_keymap
  module Csv : Ecaml.Major_mode.S_with_lazy_keymap
  module Diff : Ecaml.Major_mode.S_with_lazy_keymap
  module Git_rebase : Ecaml.Major_mode.S_with_lazy_keymap
  module Markdown : Ecaml.Major_mode.S_with_lazy_keymap
  module Message : Ecaml.Major_mode.S_with_lazy_keymap
end

module Minor_mode : sig
  val auto_fill : Ecaml.Minor_mode.t
  val semantic : Ecaml.Minor_mode.t
  val smerge : Ecaml.Minor_mode.t
  val global_whitespace : Ecaml.Minor_mode.t
  val tool_bar : Ecaml.Minor_mode.t
  val menu_bar : Ecaml.Minor_mode.t
  val scroll_bar : Ecaml.Minor_mode.t
  val column_number : Ecaml.Minor_mode.t
  val global_subword : Ecaml.Minor_mode.t
  val delete_selection : Ecaml.Minor_mode.t
  val electric_indent : Ecaml.Minor_mode.t
  val electric_pair : Ecaml.Minor_mode.t
  val show_paren : Ecaml.Minor_mode.t
  val savehist : Ecaml.Minor_mode.t
  val winner : Ecaml.Minor_mode.t
  val fido_vertical : Ecaml.Minor_mode.t
  val minibuffer_depth_indicate : Ecaml.Minor_mode.t
  val global_auto_revert : Ecaml.Minor_mode.t
  val diff : Ecaml.Minor_mode.t
end

module Browse_url : sig
  module Command : sig
    val browse_url : Ecaml.Command.t
  end
end

module Custom : sig
  val file : string option Ecaml.Customization.t
  val load_theme : ?no_confirm:bool -> ?no_enable:bool -> string -> unit
end

module Cc_mode : sig
  val common_hook : Ecaml.Hook.normal Ecaml.Hook.t
end

module Comint : sig
  val prompt_read_only : bool Ecaml.Customization.t
end

module Diff_mode : sig
  module Refine : sig
    type t = Font_lock | Navigation
  end

  val refine : Refine.t option Ecaml.Customization.t
  val default_read_only : bool Ecaml.Customization.t
end

module Eglot : sig
  module Command : sig
    val code_actions : unit -> Ecaml.Command.t
    val rename : unit -> Ecaml.Command.t
  end
end

module Eldoc : sig
  val echo_area_use_multiline_p :
    [ `Never
    | `Always
    | `Truncate_sym_name_if_fit
    | `Fraction_of_frame_height of float
    | `Number_of_lines of int ]
    Ecaml.Customization.t
end

module Files : sig
  val auto_mode_case_fold : bool Ecaml.Customization.t
  val view_read_only : bool Ecaml.Customization.t

  val require_final_newline :
    [ `Visit | `Save | `Visit_save | `Never | `Ask ] Ecaml.Customization.t
end

module Find_file : sig
  module Command : sig
    val get_other_file : Ecaml.Command.t
  end
end

module Git_commit : sig
  val feature : Ecaml.Feature.t
  val summary_max_length : int Ecaml.Customization.t
  val setup_hook : Ecaml.Hook.normal Ecaml.Hook.t
end

module Imenu : sig
  module Command : sig
    val imenu : Ecaml.Command.t
  end
end

module Indent : sig
  val tabs_mode : bool Ecaml.Customization.t
end

module Ispell : sig
  module Command : sig
    val message : Ecaml.Command.t
    val comments_and_strings : Ecaml.Command.t
    val change_dictionary : Ecaml.Command.t
    val ispell : Ecaml.Command.t
  end
end

module Man : sig
  module Command : sig
    val man : Ecaml.Command.t
  end
end

module Magit : sig
  val bind_magit_project_status : bool Ecaml.Var.t
  val commit_show_diff : bool Ecaml.Customization.t
  val define_global_key_bindings : bool Ecaml.Customization.t
end

module Markdown_mode : sig
  val cleanup_list_numbers : unit -> unit
  val command : string Ecaml.Customization.t
  val asymmetric_header : bool Ecaml.Customization.t
  val fontify_code_blocks_natively : bool Ecaml.Customization.t
end

module Minibuffer : sig
  val completions_format :
    [ `Horizontal | `Vertical | `One_column ] Ecaml.Customization.t

  val enable_recursive_minibuffers : bool Ecaml.Customization.t
end

module Novice : sig
  val disabled_command_function : Ecaml.Function.t option Ecaml.Var.t
end

module Package : sig
  val feature : Ecaml.Feature.t
  val archives : (string * string) list Ecaml.Customization.t
  val refresh_contents : ?async:bool -> unit -> unit
  val selected_packages : Ecaml.Symbol.t list Ecaml.Customization.t
  val initialize : ?no_activate:bool -> unit -> unit
  val install_selected_packages : ?no_confirm:bool -> unit -> unit
end

module Semantic : sig
  module Submode : sig
    type t

    val global_stickyfunc : t
  end

  val default_submodes : Submode.t list Ecaml.Customization.t
end

module Server : sig
  val start : ?leave_dead:bool -> ?inhibit_prompt:bool -> unit -> unit
end

module Smerge_mode : sig
  val feature : Ecaml.Symbol.t
  val begin_re : Ecaml.Regexp.t Ecaml.Var.t
end

module Startup : sig
  val initial_buffer_choice :
    [ `Scratch | `File of string | `Function of Ecaml.Function.t ] option
    Ecaml.Customization.t

  val inhibit_startup_screen : bool Ecaml.Customization.t
end

module Term : sig
  val buffer_maximum_size : int Ecaml.Customization.t
end

module Vc : sig
  val follow_symlinks :
    [ `Ask | `Visit_link_and_warn | `Follow_link ] Ecaml.Customization.t

  val command_messages : bool Ecaml.Customization.t
end

module Whitespace : sig
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
end

module Windmove : sig
  module Command : sig
    val left : Ecaml.Command.t
    val right : Ecaml.Command.t
    val up : Ecaml.Command.t
    val down : Ecaml.Command.t
  end
end

module Winner : sig
  module Command : sig
    val undo : unit -> Ecaml.Command.t
  end
end
