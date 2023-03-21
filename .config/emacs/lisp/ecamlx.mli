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
  returns:(_, 'a) Ecaml.Returns.t ->
  'a Ecaml.Defun.t ->
  unit

val global_set_key : Ecaml.Key_sequence.t -> Ecaml.Command.t -> unit
val local_set_key : Ecaml.Key_sequence.t -> Ecaml.Command.t -> unit
val local_unset_key : Ecaml.Key_sequence.t -> unit
val mode_line_compact : [ `Never | `Always | `Long ] Ecaml.Customization.t
val track_eol : bool Ecaml.Customization.t
val shell_file_name : string Ecaml.Customization.t

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
  val start : string Ecaml.Var.t
  val end_ : string Ecaml.Var.t
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
  val post_self_insert : Ecaml.Hook.normal Ecaml.Hook.t

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
  module Conf_colon : Ecaml.Major_mode.S_with_lazy_keymap
  module Conf_space : Ecaml.Major_mode.S_with_lazy_keymap
  module Conf_unix : Ecaml.Major_mode.S_with_lazy_keymap
  module Csv : Ecaml.Major_mode.S_with_lazy_keymap
  module C_plus_plus : Ecaml.Major_mode.S_with_lazy_keymap
  module Diff : Ecaml.Major_mode.S_with_lazy_keymap
  module Git_rebase : Ecaml.Major_mode.S_with_lazy_keymap
  module Gitignore : Ecaml.Major_mode.S_with_lazy_keymap
  module Java : Ecaml.Major_mode.S_with_lazy_keymap
  module Markdown : Ecaml.Major_mode.S_with_lazy_keymap
  module Message : Ecaml.Major_mode.S_with_lazy_keymap
  module Scala : Ecaml.Major_mode.S_with_lazy_keymap
  module Sh : Ecaml.Major_mode.S_with_lazy_keymap
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
  val flyspell : Ecaml.Minor_mode.t
  val reftex : Ecaml.Minor_mode.t
  val auto_insert : Ecaml.Minor_mode.t
end

module Regexp : sig
  val match_string : ?string:string -> int -> string option
end

module Ansi_color : sig
  val compilation_filter : unit -> unit
end

module Auctex : sig
  module Latex : sig
    module Minor_mode : sig
      val math : Ecaml.Minor_mode.t
    end

    val mode_hook : Ecaml.Hook.normal Ecaml.Hook.t

    val section_hook :
      [ `Heading | `Title | `Toc | `Section | `Label ] list
      Ecaml.Customization.t
  end

  module Tex : sig
    module Minor_mode : sig
      val pdf : Ecaml.Minor_mode.t
      val source_correlate : Ecaml.Minor_mode.t
    end

    val auto_save : bool Ecaml.Customization.t
    val parse_self : bool Ecaml.Customization.t
    val electric_math : (string * string) option Ecaml.Customization.t
    val electric_sub_and_superscript : bool Ecaml.Customization.t

    val master :
      [ `Query | `This_file | `Shared | `Dwim | `File of string ]
      Ecaml.Customization.t
  end

  val font_latex_fontify_script :
    [ `Yes | `No | `Multi_level | `Invisible ] Ecaml.Customization.t
end

module Auto_insert : sig
  val define :
    ?after:bool ->
    ?description:string ->
    [ `Regexp of Ecaml.Regexp.t | `Major_mode of Ecaml.Major_mode.t ] ->
    [ `File of string | `Function of Ecaml.Function.t ] ->
    unit

  val directory : string Ecaml.Customization.t
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
  val initialization_hook : Ecaml.Hook.normal Ecaml.Hook.t

  module Default_style : sig
    type t = {
      other : string option;
      major_modes : (Ecaml.Major_mode.t * string) list;
    }
  end

  val default_style : Default_style.t Ecaml.Customization.t
end

module Comint : sig
  val prompt_read_only : bool Ecaml.Customization.t
end

module Compilation : sig
  val feature : Ecaml.Feature.t
  val scroll_output : [ `Yes | `No | `First_error ] Ecaml.Customization.t

  val context_lines :
    [ `Scroll_when_no_fringe | `Never_scroll | `Number_of_lines of int ]
    Ecaml.Customization.t

  val filter_hook : Ecaml.Hook.normal Ecaml.Hook.t

  module Error_matcher : sig
    type subexpression = int

    type type_ =
      | Explicit of [ `Error | `Warning | `Info ]
      | Conditional of {
          warning_if_match : subexpression;
          info_if_match : subexpression;
        }

    type range = {
      start :
        [ `Subexpression of subexpression | `Function of Ecaml.Function.t ];
      end_ :
        [ `Subexpression of subexpression | `Function of Ecaml.Function.t ]
        option;
    }

    type t = {
      regexp : Ecaml.Regexp.t;
      file :
        [ `Subexpression of subexpression * string list
        | `Function of Ecaml.Function.t ];
      line : range option;
      column : range option;
      type_ : type_;
      hyperlink : subexpression option;
      highlights :
        (subexpression * Ecaml.Face.t * Ecaml.Face.Attribute_and_value.t list)
        list;
    }
  end

  val error_regexp_alist :
    [ `Error_matcher of Error_matcher.t | `Symbol of Ecaml.Symbol.t ] list
    Ecaml.Customization.t
end

module Debian_el : sig
  val feature : Ecaml.Feature.t
end

module Diff_mode : sig
  module Refine : sig
    type t = Font_lock | Navigation
  end

  val refine : Refine.t option Ecaml.Customization.t
  val default_read_only : bool Ecaml.Customization.t
end

module Dired : sig
  val completion_ignored_extensions : string list Ecaml.Customization.t
end

module Eglot : sig
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
  val line_function : Ecaml.Function.t Ecaml.Var.t
  val relative : Ecaml.Function.t
end

module Ispell : sig
  module Command : sig
    val message : Ecaml.Command.t
    val comments_and_strings : Ecaml.Command.t
    val change_dictionary : Ecaml.Command.t
    val ispell : Ecaml.Command.t
  end

  val program_name : string Ecaml.Customization.t
  val change_dictionary : ?globally:bool -> string -> unit
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

module Proof_general : sig
  module Coq : sig
    val one_command_per_line : bool Ecaml.Customization.t
  end

  val splash_enable : bool Ecaml.Customization.t

  val three_window_mode_policy :
    [ `Smart | `Horizontal | `Hybrid | `Vertical ] Ecaml.Customization.t
end

module Reftex : sig
  type auctex_plugins = {
    supply_labels_in_new_sections_and_environments : bool;
    supply_arguments_for_macros_like_label : bool;
    supply_arguments_for_macros_like_ref : bool;
    supply_arguments_for_macros_like_cite : bool;
    supply_arguments_for_macros_like_index : bool;
  }

  val plug_into_auctex : auctex_plugins Ecaml.Customization.t
  val enable_partial_scans : bool Ecaml.Customization.t
  val save_parse_info : bool Ecaml.Customization.t
  val use_multiple_selection_buffers : bool Ecaml.Customization.t
end

module Scala_mode : sig
  module Indent : sig
    val default_run_on_strategy :
      [ `Eager | `Operators | `Reluctant ] Ecaml.Customization.t
  end
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
  val ansi_term : ?new_buffer_name:string -> string -> Ecaml.Buffer.t
end

module Tuareg : sig
  val interactive_read_only_input : bool Ecaml.Customization.t
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
