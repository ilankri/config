type position = string * int * int * int

let position ~__POS__:(pos_fname, pos_lnum, pos_cnum, _) =
  { Lexing.pos_fname; pos_lnum; pos_cnum; pos_bol = 0 }

let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecaml.defun (Ecaml.Symbol.intern name) (position ~__POS__)
    ~docstring:(Option.value ~default:"None" docstring)
    ?define_keys ?obsoletes ?should_profile ?interactive ?disabled ?evil_config
    returns f

let global_set_key =
  let open Ecaml.Funcall.Wrap in
  "global-set-key"
  <: Ecaml.Key_sequence.type_ @-> Ecaml.Command.type_ @-> return nil

let local_set_key =
  let open Ecaml.Funcall.Wrap in
  "local-set-key"
  <: Ecaml.Key_sequence.type_ @-> Ecaml.Command.type_ @-> return nil

module Value = struct
  module Type = struct
    let enum (type a) name (module Type : Enum.S with type t = a) =
      Ecaml.Value.Type.enum (Sexplib0.Sexp.Atom name)
        (module Type)
        (fun value ->
          value |> Type.sexp_of_t |> Sexplib0.Sexp.to_string
          |> Ecaml.Value.intern)
  end
end

let mode_line_compact =
  let type_ =
    let module Type = struct
      type t = [ `Never | `Always | `Long ]

      let all = [ `Never; `Always; `Long ]

      let sexp_of_t value =
        let atom =
          match value with `Never -> "nil" | `Always -> "t" | `Long -> "long"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "mode-line-compact" (module Type)
  in
  let open Ecaml.Customization.Wrap in
  "mode-line-compact" <: type_

let track_eol =
  let open Ecaml.Customization.Wrap in
  "track-eol" <: bool

let shell_file_name =
  let open Ecaml.Customization.Wrap in
  "shell-file-name" <: string

module Command = struct
  let from_string name =
    name |> Ecaml.Value.intern |> Ecaml.Command.of_value_exn

  let blink_matching_open = from_string "blink-matching-open"
  let switch_to_completions = from_string "switch-to-completions"
end

module Customization = struct
  let set_value variable value_ =
    let custom_set_variables =
      let open Ecaml.Funcall.Wrap in
      "custom-set-variables" <: value @-> return nil
    in
    let variable = Ecaml.Customization.var variable in
    custom_set_variables
    @@ Ecaml.Value.list
         [
           variable |> Ecaml.Var.symbol |> Ecaml.Symbol.to_value;
           value_
           |> Ecaml.Value.Type.to_value variable.Ecaml.Var.type_
           |> Ecaml.Form.quote |> Ecaml.Form.to_value;
         ]

  let from_variable variable =
    let open Ecaml.Customization.Wrap in
    variable |> Ecaml.Var.symbol |> Ecaml.Symbol.name
    <: Ecaml.Var.type_ variable
end

module Current_buffer = struct
  let fill_column =
    Ecaml.Current_buffer.fill_column |> Ecaml.Buffer_local.var
    |> Customization.from_variable

  let inhibit_read_only =
    let open Ecaml.Var.Wrap in
    "inhibit-read-only" <: bool

  let set_buffer_local variable value =
    Ecaml.Current_buffer.set_buffer_local
      (Ecaml.Buffer_local.wrap_existing ~make_buffer_local_always:true
         (Ecaml.Var.symbol variable)
         (Ecaml.Var.type_ variable))
      value

  let set_customization_buffer_local variable value =
    let variable = Ecaml.Customization.var variable in
    set_buffer_local variable value

  let scroll_up_aggressively =
    let open Ecaml.Customization.Wrap in
    "scroll-up-aggressively" <: nil_or Ecaml.Customization.Wrap.float

  let scroll_down_aggressively =
    let open Ecaml.Customization.Wrap in
    "scroll-down-aggressively" <: nil_or Ecaml.Customization.Wrap.float
end

module Comment = struct
  let multi_line =
    let open Ecaml.Customization.Wrap in
    "comment-multi-line" <: bool
end

module Fill = struct
  let nobreak_predicate =
    let open Ecaml.Customization.Wrap in
    "fill-nobreak-predicate" <: list Ecaml.Function.t

  let french_nobreak_p =
    "fill-french-nobreak-p" |> Ecaml.Symbol.intern |> Ecaml.Function.of_symbol
end

module Frame = struct
  let toggle_fullscreen ?frame () =
    let toggle_fullscreen =
      let open Ecaml.Funcall.Wrap in
      "toggle-frame-fullscreen" <: nil_or Ecaml.Frame.type_ @-> return nil
    in
    toggle_fullscreen frame
end

module Hook = struct
  let find_file =
    let open Ecaml.Hook.Wrap in
    "find-file-hook" <: Ecaml.Hook.Hook_type.Normal_hook

  module Function = struct
    let create ~name ~__POS__ ?docstring ?should_profile ~hook_type ~returns f =
      Ecaml.Hook.Function.create (Ecaml.Symbol.intern name) (position ~__POS__)
        ~docstring:(Option.value ~default:"None" docstring)
        ?should_profile ~hook_type (Ecaml.Returns.Returns returns) f
  end
end

module Major_mode = struct
  module Archive =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "archive-mode"
           (position ~__POS__))

  module Conf =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "conf-mode"
           (position ~__POS__))

  module Conf_colon =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "conf-colon-mode"
           (position ~__POS__))

  module Conf_space =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "conf-space-mode"
           (position ~__POS__))

  module Conf_unix =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "conf-unix-mode"
           (position ~__POS__))

  module Csv =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "csv-mode"
           (position ~__POS__))

  module Diff =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "diff-mode"
           (position ~__POS__))

  module Dune =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "dune-mode"
           (position ~__POS__))

  module Git_rebase =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "git-rebase-mode"
           (position ~__POS__))

  module Gitignore =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "gitignore-mode"
           (position ~__POS__))

  module Markdown =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "markdown-mode"
           (position ~__POS__))

  module Message =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "message-mode"
           (position ~__POS__))

  module Sh =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "sh-mode"
           (position ~__POS__))
end

module Minor_mode = struct
  let make ?variable_name function_name =
    let variable_name = Option.map Ecaml.Symbol.intern variable_name in
    let function_name = Ecaml.Symbol.intern function_name in
    Ecaml.Minor_mode.create ?variable_name function_name

  let auto_fill = make "auto-fill-mode"
  let semantic = make "semantic-mode"
  let smerge = make "smerge-mode"
  let global_whitespace = make "global-whitespace-mode"
  let tool_bar = make "tool-bar-mode"
  let menu_bar = make "menu-bar-mode"
  let scroll_bar = make "scroll-bar-mode"
  let column_number = make "column-number-mode"
  let global_subword = make "global-subword-mode"
  let delete_selection = make "delete-selection-mode"
  let electric_indent = make "electric-indent-mode"
  let electric_pair = make "electric-pair-mode"
  let show_paren = make "show-paren-mode"
  let savehist = make "savehist-mode"
  let winner = make "winner-mode"
  let fido_vertical = make "fido-vertical-mode"
  let minibuffer_depth_indicate = make "minibuffer-depth-indicate-mode"
  let global_auto_revert = make "global-auto-revert-mode"
  let diff = make "diff-minor-mode"
end

module Browse_url = struct
  module Command = struct
    let browse_url = Command.from_string "browse-url"
  end
end

module Custom = struct
  let load_theme ?no_confirm ?no_enable theme =
    let load_theme =
      let open Ecaml.Funcall.Wrap in
      "load-theme"
      <: Ecaml.Symbol.t @-> nil_or bool @-> nil_or bool @-> return nil
    in
    load_theme (Ecaml.Symbol.intern theme) no_confirm no_enable

  let file =
    let open Ecaml.Customization.Wrap in
    "custom-file" <: nil_or string
end

module Cc_mode = struct
  let common_hook =
    let open Ecaml.Hook.Wrap in
    "c-mode-common-hook" <: Ecaml.Hook.Hook_type.Normal_hook
end

module Comint = struct
  let prompt_read_only =
    let open Ecaml.Customization.Wrap in
    "comint-prompt-read-only" <: bool
end

module Diff_mode = struct
  module Refine = struct
    type t = Font_lock | Navigation

    let type_ =
      let module Type = struct
        type nonrec t = t

        let all = [ Font_lock; Navigation ]

        let sexp_of_t value =
          let atom =
            match value with
            | Font_lock -> "font-lock"
            | Navigation -> "navigation"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "diff-refine" (module Type)
  end

  let refine =
    let open Ecaml.Customization.Wrap in
    "diff-refine" <: nil_or Refine.type_

  let default_read_only =
    let open Ecaml.Customization.Wrap in
    "diff-default-read-only" <: bool
end

module Dired = struct
  let completion_ignored_extensions =
    let open Ecaml.Customization.Wrap in
    "completion-ignored-extensions" <: list string
end

module Eldoc = struct
  let echo_area_use_multiline_p =
    let type_ =
      let truncate_sym_name_if_fit =
        Ecaml.Value.intern "truncate-sym-name-if-fit"
      in
      let to_ value =
        if Ecaml.Value.eq value Ecaml.Value.t then `Always
        else if Ecaml.Value.eq value Ecaml.Value.nil then `Never
        else if Ecaml.Value.eq value truncate_sym_name_if_fit then
          `Truncate_sym_name_if_fit
        else if Ecaml.Value.is_integer value then
          `Number_of_lines (Ecaml.Value.to_int_exn value)
        else if Ecaml.Value.is_float value then
          `Fraction_of_frame_height (Ecaml.Value.to_float_exn value)
        else assert false
      in
      let from = function
        | `Always -> Ecaml.Value.t
        | `Never -> Ecaml.Value.nil
        | `Truncate_sym_name_if_fit -> truncate_sym_name_if_fit
        | `Number_of_lines i -> Ecaml.Value.of_int_exn i
        | `Fraction_of_frame_height f -> Ecaml.Value.of_float f
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create
        (Sexplib0.Sexp.Atom "eldoc-echo-area-use-multiline-p") to_sexp to_ from
    in
    let open Ecaml.Customization.Wrap in
    "eldoc-echo-area-use-multiline-p" <: type_
end

module Eglot = struct
  let feature = Ecaml.Symbol.intern "eglot"

  module Command = struct
    let code_actions () =
      Ecaml.Feature.require feature;
      Command.from_string "eglot-code-actions"

    let rename () =
      Ecaml.Feature.require feature;
      Command.from_string "eglot-rename"
  end
end

module Files = struct
  let view_read_only =
    let open Ecaml.Customization.Wrap in
    "view-read-only" <: bool

  let auto_mode_case_fold =
    let open Ecaml.Customization.Wrap in
    "auto-mode-case-fold" <: bool

  let require_final_newline =
    let type_ =
      let module Type = struct
        type t = [ `Visit | `Save | `Visit_save | `Never | `Ask ]

        let all = [ `Visit; `Save; `Visit_save; `Never; `Ask ]

        let sexp_of_t value =
          let atom =
            match value with
            | `Visit -> "visit"
            | `Save -> "t"
            | `Visit_save -> "visit-save"
            | `Never -> "nil"
            | `Ask -> "ask"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "require-final-newline" (module Type)
    in
    let open Ecaml.Customization.Wrap in
    "require-final-newline" <: type_
end

module Find_file = struct
  module Command = struct
    let get_other_file = Command.from_string "ff-get-other-file"
  end
end

module Git_commit = struct
  let feature = Ecaml.Symbol.intern "git-commit"

  let summary_max_length =
    let open Ecaml.Customization.Wrap in
    "git-commit-summary-max-length" <: int

  let setup_hook =
    let open Ecaml.Hook.Wrap in
    "git-commit-setup-hook" <: Ecaml.Hook.Hook_type.Normal_hook
end

module Imenu = struct
  module Command = struct
    let imenu = Command.from_string "imenu"
  end
end

module Ispell = struct
  module Command = struct
    let message = Command.from_string "ispell-message"
    let comments_and_strings = Command.from_string "ispell-comments-and-strings"
    let change_dictionary = Command.from_string "ispell-change-dictionary"
    let ispell = Command.from_string "ispell"
  end
end

module Semantic = struct
  module Submode = struct
    type t = Ecaml.Minor_mode.t

    let global_stickyfunc = Minor_mode.make "global-semantic-stickyfunc-mode"

    let type_ =
      let to_ value = value |> Ecaml.Value.prin1_to_string |> Minor_mode.make in
      let from minor_mode =
        (Ecaml.Minor_mode.function_name minor_mode :> Ecaml.Value.t)
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "semantic-submodes") to_sexp
        to_ from
  end

  let default_submodes =
    let open Ecaml.Customization.Wrap in
    "semantic-default-submodes" <: list Submode.type_
end

module Server = struct
  let start ?leave_dead ?inhibit_prompt () =
    let start =
      let open Ecaml.Funcall.Wrap in
      "server-start" <: nil_or bool @-> nil_or bool @-> return nil
    in
    start leave_dead inhibit_prompt
end

module Indent = struct
  let tabs_mode =
    let open Ecaml.Customization.Wrap in
    "indent-tabs-mode" <: bool
end

module Magit = struct
  let bind_magit_project_status =
    let open Ecaml.Var.Wrap in
    "magit-bind-magit-project-status" <: bool

  let commit_show_diff =
    let open Ecaml.Customization.Wrap in
    "magit-commit-show-diff" <: bool

  let define_global_key_bindings =
    let open Ecaml.Customization.Wrap in
    "magit-define-global-key-bindings" <: bool
end

module Markdown_mode = struct
  let cleanup_list_numbers =
    let open Ecaml.Funcall.Wrap in
    "markdown-cleanup-list-numbers" <: nullary @-> return nil

  let command =
    let open Ecaml.Customization.Wrap in
    "markdown-command" <: string

  let asymmetric_header =
    let open Ecaml.Customization.Wrap in
    "markdown-asymmetric-header" <: bool

  let fontify_code_blocks_natively =
    let open Ecaml.Customization.Wrap in
    "markdown-fontify-code-blocks-natively" <: bool
end

module Man = struct
  module Command = struct
    let man = Command.from_string "man"
  end
end

module Minibuffer = struct
  let completions_format =
    let type_ =
      let module Type = struct
        type t = [ `Horizontal | `Vertical | `One_column ]

        let all = [ `Horizontal; `Vertical; `One_column ]

        let sexp_of_t value =
          let atom =
            match value with
            | `Horizontal -> "horizontal"
            | `Vertical -> "vertical"
            | `One_column -> "one-column"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "completions-format" (module Type)
    in
    let open Ecaml.Customization.Wrap in
    "completions-format" <: type_

  let enable_recursive_minibuffers =
    let open Ecaml.Customization.Wrap in
    "enable-recursive-minibuffers" <: bool
end

module Novice = struct
  let disabled_command_function =
    let open Ecaml.Var.Wrap in
    "disabled-command-function" <: nil_or Ecaml.Function.t
end

module Package = struct
  let feature = Ecaml.Symbol.intern "package"

  let archives =
    let open Ecaml.Customization.Wrap in
    "package-archives" <: list (tuple string string)

  let refresh_contents ?async () =
    let refresh_contents =
      let open Ecaml.Funcall.Wrap in
      "package-refresh-contents" <: nil_or bool @-> return unit
    in
    refresh_contents async

  let selected_packages =
    let open Ecaml.Customization.Wrap in
    "package-selected-packages" <: list Ecaml.Symbol.type_

  let initialize ?no_activate () =
    let initialize =
      let open Ecaml.Funcall.Wrap in
      "package-initialize" <: nil_or bool @-> return unit
    in
    initialize no_activate

  let install_selected_packages ?no_confirm () =
    let install_selected_packages =
      let open Ecaml.Funcall.Wrap in
      "package-install-selected-packages" <: nil_or bool @-> return string
    in
    ignore (install_selected_packages no_confirm)
end

module Startup = struct
  let initial_buffer_choice =
    let type_ =
      let to_ value =
        if Ecaml.Value.eq value Ecaml.Value.t then `Scratch
        else if Ecaml.Value.is_string value then
          `File (Ecaml.Value.to_utf8_bytes_exn value)
        else `Function (Ecaml.Function.of_value_exn value)
      in
      let from = function
        | `Scratch -> Ecaml.Value.t
        | `File s -> Ecaml.Value.of_utf8_bytes s
        | `Function f -> Ecaml.Function.to_value f
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "initial-buffer-choice")
        to_sexp to_ from
    in
    let open Ecaml.Customization.Wrap in
    "initial-buffer-choice" <: nil_or type_

  let inhibit_startup_screen =
    let open Ecaml.Customization.Wrap in
    "inhibit-startup-screen" <: bool
end

module Smerge_mode = struct
  let feature = Ecaml.Symbol.intern "smerge-mode"

  let begin_re =
    let open Ecaml.Var.Wrap in
    "smerge-begin-re" <: Ecaml.Regexp.t
end

module Term = struct
  let buffer_maximum_size =
    let open Ecaml.Customization.Wrap in
    "term-buffer-maximum-size" <: int

  let ansi_term ?new_buffer_name program =
    let ansi_term =
      let open Ecaml.Funcall.Wrap in
      "ansi-term" <: string @-> nil_or string @-> return Ecaml.Buffer.type_
    in
    ansi_term program new_buffer_name
end

module Vc = struct
  let follow_symlinks =
    let type_ =
      let module Type = struct
        type t = [ `Ask | `Visit_link_and_warn | `Follow_link ]

        let all = [ `Ask; `Visit_link_and_warn; `Follow_link ]

        let sexp_of_t value =
          let atom =
            match value with
            | `Ask -> "ask"
            | `Visit_link_and_warn -> "nil"
            | `Follow_link -> "t"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "vc-follow-symlinks" (module Type)
    in
    let open Ecaml.Customization.Wrap in
    "vc-follow-symlinks" <: type_

  let command_messages =
    let open Ecaml.Customization.Wrap in
    "vc-command-messages" <: bool
end

module Whitespace = struct
  module Command = struct
    let cleanup = Command.from_string "whitespace-cleanup"
  end

  module Style = struct
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

    let type_ =
      let module Type = struct
        type nonrec t = t

        let all =
          [
            Face;
            Trailing;
            Tabs;
            Spaces;
            Lines;
            Lines_tail;
            Newline;
            Missing_newline_at_eof;
            Empty;
            Indentation (Some Tab);
            Indentation (Some Space);
            Indentation None;
            Big_indent;
            Space_after_tab (Some Tab);
            Space_after_tab (Some Space);
            Space_after_tab None;
            Space_before_tab (Some Tab);
            Space_before_tab (Some Space);
            Space_before_tab None;
            Space_mark;
            Tab_mark;
            Newline_mark;
          ]

        let sexp_of_t value =
          let atom =
            match value with
            | Face -> "face"
            | Trailing -> "trailing"
            | Tabs -> "tabs"
            | Spaces -> "spaces"
            | Lines -> "lines"
            | Lines_tail -> "lines-tail"
            | Newline -> "newline"
            | Missing_newline_at_eof -> "missing-newline-at-eof"
            | Empty -> "empty"
            | Indentation (Some Tab) -> "indentation::tab"
            | Indentation (Some Space) -> "indentation::space"
            | Indentation None -> "indentation"
            | Big_indent -> "big-indent"
            | Space_after_tab (Some Tab) -> "space-after-tab::tab"
            | Space_after_tab (Some Space) -> "space-after-tab::space"
            | Space_after_tab None -> "space-after-tab"
            | Space_before_tab (Some Tab) -> "space-before-tab::tab"
            | Space_before_tab (Some Space) -> "space-before-tab::space"
            | Space_before_tab None -> "space-before-tab"
            | Space_mark -> "space-mark"
            | Tab_mark -> "tab-mark"
            | Newline_mark -> "newline-mark"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "whitespace-style" (module Type)
  end

  let style =
    let open Ecaml.Customization.Wrap in
    "whitespace-style" <: list Style.type_

  module Action = struct
    type t =
      | Cleanup
      | Report_on_bogus
      | Auto_cleanup
      | Abort_on_bogus
      | Warn_if_read_only

    let type_ =
      let module Type = struct
        type nonrec t = t

        let all =
          [
            Cleanup;
            Report_on_bogus;
            Auto_cleanup;
            Abort_on_bogus;
            Warn_if_read_only;
          ]

        let sexp_of_t value =
          let atom =
            match value with
            | Cleanup -> "cleanup"
            | Report_on_bogus -> "report-on-bogus"
            | Auto_cleanup -> "auto-cleanup"
            | Abort_on_bogus -> "abort-on-bogus"
            | Warn_if_read_only -> "warn-if-read-only"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "whitespace-action" (module Type)
  end

  let action =
    let open Ecaml.Customization.Wrap in
    "whitespace-action" <: list Action.type_

  module Global_modes = struct
    type t =
      | All of { except : Ecaml.Major_mode.t list }
      | Only of Ecaml.Major_mode.t list

    let type_ =
      let not_ = Ecaml.Value.intern "not" in
      let to_ value =
        if Ecaml.Value.eq value Ecaml.Value.t then All { except = [] }
        else
          match Ecaml.Value.to_list_exn ~f:Ecaml.Symbol.of_value_exn value with
          | [] -> Only []
          | maybe_not :: except as major_modes ->
              if Ecaml.Value.eq (maybe_not :> Ecaml.Value.t) not_ then
                let except =
                  List.map
                    (Ecaml.Major_mode.find_or_wrap_existing (position ~__POS__))
                    except
                in
                All { except }
              else
                let major_modes =
                  List.map
                    (Ecaml.Major_mode.find_or_wrap_existing (position ~__POS__))
                    major_modes
                in
                Only major_modes
      in

      let from = function
        | All { except = [] } -> Ecaml.Value.t
        | All { except = _ :: _ as except } ->
            Ecaml.Value.list
              (not_
              :: (List.map Ecaml.Major_mode.symbol except :> Ecaml.Value.t list)
              )
        | Only major_modes ->
            Ecaml.Value.list
              (List.map Ecaml.Major_mode.symbol major_modes
                :> Ecaml.Value.t list)
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "whitespace-global-modes")
        to_sexp to_ from
  end

  let global_modes =
    let open Ecaml.Customization.Wrap in
    "whitespace-global-modes" <: Global_modes.type_
end

module Windmove = struct
  module Command = struct
    let left = Command.from_string "windmove-left"
    let right = Command.from_string "windmove-right"
    let up = Command.from_string "windmove-up"
    let down = Command.from_string "windmove-down"
  end
end

module Winner = struct
  let feature = Ecaml.Symbol.intern "winner"

  module Command = struct
    let undo () =
      Ecaml.Feature.require feature;
      Command.from_string "winner-undo"
  end
end
