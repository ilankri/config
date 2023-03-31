type position = string * int * int * int

let position ~__POS__:(pos_fname, pos_lnum, pos_cnum, _) =
  { Lexing.pos_fname; pos_lnum; pos_cnum; pos_bol = 0 }

let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecaml.defun (Ecaml.Symbol.intern name) (position ~__POS__)
    ~docstring:(Option.value ~default:"None" docstring)
    ?define_keys ?obsoletes ?should_profile ?interactive ?disabled ?evil_config
    returns f

let lambda ~__POS__ ?docstring ?interactive ~returns f =
  Ecaml.lambda (position ~__POS__) ?docstring ?interactive returns f

let global_set_key =
  let open Ecaml.Funcall.Wrap in
  "global-set-key"
  <: Ecaml.Key_sequence.type_ @-> Ecaml.Command.type_ @-> return nil

let local_set_key =
  let open Ecaml.Funcall.Wrap in
  "local-set-key"
  <: Ecaml.Key_sequence.type_ @-> Ecaml.Command.type_ @-> return nil

let local_unset_key =
  let open Ecaml.Funcall.Wrap in
  "local-unset-key" <: Ecaml.Key_sequence.type_ @-> return nil

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

let user_emacs_directory =
  let open Ecaml.Var.Wrap in
  "user-emacs-directory" <: string

let load_prefer_newer =
  let open Ecaml.Var.Wrap in
  "load-prefer-newer" <: bool

module Command = struct
  let from_string name =
    name |> Ecaml.Value.intern |> Ecaml.Command.of_value_exn

  let blink_matching_open = from_string "blink-matching-open"
  let switch_to_completions = from_string "switch-to-completions"
  let kill_current_buffer = from_string "kill-current-buffer"
end

module Customization = struct
  let set_value variable value_ =
    let customize_set_variable =
      let open Ecaml.Funcall.Wrap in
      "customize-set-variable"
      <: Ecaml.Symbol.type_ @-> value @-> nil_or string @-> return nil
    in
    let variable = Ecaml.Customization.var variable in
    customize_set_variable
      (Ecaml.Var.symbol variable)
      (Ecaml.Value.Type.to_value variable.Ecaml.Var.type_ value_)
      None

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

  let start =
    let open Ecaml.Var.Wrap in
    "comment-start" <: string

  let end_ =
    let open Ecaml.Var.Wrap in
    "comment-end" <: string
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

  let post_self_insert =
    let open Ecaml.Hook.Wrap in
    "post-self-insert-hook" <: Ecaml.Hook.Hook_type.Normal_hook

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

  module C_plus_plus =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "c++-mode"
           (position ~__POS__))

  module Diff =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "diff-mode"
           (position ~__POS__))

  module Git_rebase =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "git-rebase-mode"
           (position ~__POS__))

  module Gitignore =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "gitignore-mode"
           (position ~__POS__))

  module Java =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "java-mode"
           (position ~__POS__))

  module Latex =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "latex-mode"
           (position ~__POS__))

  module Markdown =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "markdown-mode"
           (position ~__POS__))

  module Message =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "message-mode"
           (position ~__POS__))

  module Scala =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "scala-mode"
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
  let flyspell = make "flyspell-mode"
  let reftex = make "reftex-mode"
  let auto_insert = make "auto-insert-mode"
  let global_goto_address = make "global-goto-address-mode"
end

module Regexp = struct
  let match_string ?(with_text_properties = false) ?string:s n =
    let match_string =
      let open Ecaml.Funcall.Wrap in
      (if with_text_properties then "match-string"
      else "match-string-no-properties")
      <: int @-> nil_or string @-> return (nil_or string)
    in
    match_string n s
end

module Ansi_color = struct
  let compilation_filter =
    let open Ecaml.Funcall.Wrap in
    "ansi-color-compilation-filter" <: nullary @-> return nil
end

module Auctex = struct
  module Latex = struct
    module Minor_mode = struct
      let math = Minor_mode.make "LaTeX-math-mode"
    end

    let mode_hook =
      let open Ecaml.Hook.Wrap in
      "LaTeX-mode-hook" <: Ecaml.Hook.Hook_type.Normal_hook

    let section_hook =
      let type_ =
        let module Type = struct
          type t = [ `Heading | `Title | `Toc | `Section | `Label ]

          let all = [ `Heading; `Title; `Toc; `Section; `Label ]

          let sexp_of_t value =
            let hook =
              match value with
              | `Heading -> "heading"
              | `Title -> "title"
              | `Toc -> "toc"
              | `Section -> "section"
              | `Label -> "label"
            in
            Sexplib0.Sexp.Atom (Format.sprintf "LaTeX-section-%s" hook)
        end in
        Value.Type.enum "LaTeX-section-hook" (module Type)
      in
      let open Ecaml.Customization.Wrap in
      "LaTeX-section-hook" <: list type_
  end

  module Tex = struct
    module Minor_mode = struct
      let pdf = Minor_mode.make "TeX-PDF-mode"
      let source_correlate = Minor_mode.make "TeX-source-correlate-mode"
    end

    let auto_save =
      let open Ecaml.Customization.Wrap in
      "TeX-auto-save" <: bool

    let parse_self =
      let open Ecaml.Customization.Wrap in
      "TeX-parse-self" <: bool

    let electric_math =
      let type_ =
        let to_ value =
          if Ecaml.Value.is_nil value then None
          else
            Some
              ( value |> Ecaml.Value.car_exn |> Ecaml.Value.to_utf8_bytes_exn,
                value |> Ecaml.Value.cdr_exn |> Ecaml.Value.to_utf8_bytes_exn )
        in
        let from = function
          | None -> Ecaml.Value.nil
          | Some (before, after) ->
              Ecaml.Value.cons
                (Ecaml.Value.of_utf8_bytes before)
                (Ecaml.Value.of_utf8_bytes after)
        in
        let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
        Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "TeX-electric-math") to_sexp
          to_ from
      in
      let open Ecaml.Customization.Wrap in
      "TeX-electric-math" <: type_

    let electric_sub_and_superscript =
      let open Ecaml.Customization.Wrap in
      "TeX-electric-sub-and-superscript" <: bool

    let master =
      let type_ =
        let shared = Ecaml.Value.intern "shared" in
        let dwim = Ecaml.Value.intern "dwim" in
        let to_ value =
          if Ecaml.Value.is_nil value then `Query
          else if Ecaml.Value.eq value Ecaml.Value.t then `This_file
          else if Ecaml.Value.eq value shared then `Shared
          else if Ecaml.Value.eq value dwim then `Dwim
          else `File (Ecaml.Value.to_utf8_bytes_exn value)
        in
        let from = function
          | `Query -> Ecaml.Value.nil
          | `This_file -> Ecaml.Value.t
          | `Shared -> shared
          | `Dwim -> dwim
          | `File file -> Ecaml.Value.of_utf8_bytes file
        in
        let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
        Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "TeX-master") to_sexp to_
          from
      in
      let open Ecaml.Customization.Wrap in
      "TeX-master" <: type_
  end

  let font_latex_fontify_script =
    let type_ =
      let module Type = struct
        type t = [ `Yes | `No | `Multi_level | `Invisible ]

        let all = [ `Yes; `No; `Multi_level; `Invisible ]

        let sexp_of_t value =
          let atom =
            match value with
            | `Yes -> "t"
            | `No -> "nil"
            | `Multi_level -> "multi-level"
            | `Invisible -> "invisible"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "font-latex-fontify-script" (module Type)
    in

    let open Ecaml.Customization.Wrap in
    "font-latex-fontify-script" <: type_
end

module Auto_insert = struct
  let define ?after ?description condition action =
    let condition_type =
      let to_ value =
        if Ecaml.Value.is_symbol value then
          `Major_mode
            (Ecaml.Major_mode.find_or_wrap_existing (position ~__POS__)
               (Ecaml.Symbol.of_value_exn value))
        else `Regexp (Ecaml.Regexp.of_value_exn value)
      in
      let from = function
        | `Major_mode m -> m |> Ecaml.Major_mode.symbol |> Ecaml.Symbol.to_value
        | `Regexp r -> Ecaml.Regexp.to_value r
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create
        (Sexplib0.Sexp.Atom "define-auto-insert-condition") to_sexp to_ from
    in
    let define condition =
      let action =
        let to_ value =
          if Ecaml.Value.is_function value then
            `Function (Ecaml.Function.of_value_exn value)
          else `File (Ecaml.Value.to_utf8_bytes_exn value)
        in
        let from = function
          | `Function f -> Ecaml.Function.to_value f
          | `File f -> Ecaml.Value.of_utf8_bytes f
        in
        let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
        Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "define-auto-insert-action")
          to_sexp to_ from
      in
      let open Ecaml.Funcall.Wrap in
      "define-auto-insert"
      <: condition @-> action @-> nil_or bool @-> return nil
    in
    match description with
    | None -> (define condition_type) condition action after
    | Some description ->
        let open Ecaml.Funcall.Wrap in
        (define (tuple condition_type string))
          (condition, description) action after

  let directory =
    let open Ecaml.Customization.Wrap in
    "auto-insert-directory" <: string
end

module Ffap = struct
  module Command = struct
    let find_file_at_point = Command.from_string "find-file-at-point"
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

  let initialization_hook =
    let open Ecaml.Hook.Wrap in
    "c-initialization-hook" <: Ecaml.Hook.Hook_type.Normal_hook

  module Default_style = struct
    type t = {
      other : string option;
      major_modes : (Ecaml.Major_mode.t * string) list;
    }

    let type_ =
      let other = Ecaml.Value.intern "other" in
      let to_ value =
        let other, major_modes =
          if Ecaml.Value.is_string value then
            (Some (Ecaml.Value.to_utf8_bytes_exn value), [])
          else
            let styles =
              Ecaml.Value.to_list_exn
                ~f:(fun value ->
                  let major_mode =
                    let major_mode = Ecaml.Value.car_exn value in
                    if Ecaml.Value.eq major_mode other then `Other
                    else
                      `Major_mode
                        (Ecaml.Major_mode.find_or_wrap_existing
                           (position ~__POS__)
                           (Ecaml.Symbol.of_value_exn major_mode))
                  in
                  let style =
                    value |> Ecaml.Value.cdr_exn
                    |> Ecaml.Value.to_utf8_bytes_exn
                  in
                  (major_mode, style))
                value
            in
            List.fold_right
              (fun (major_mode, style) (other, major_modes) ->
                match major_mode with
                | `Other -> (Some style, major_modes)
                | `Major_mode major_mode ->
                    (other, (major_mode, style) :: major_modes))
              styles (None, [])
        in
        { other; major_modes }
      in
      let from { other = other_style; major_modes } =
        let other_style =
          Option.map
            (fun other_style ->
              Ecaml.Value.cons other (Ecaml.Value.of_utf8_bytes other_style))
            other_style
        in
        let from_entry (major_mode, style) =
          Ecaml.Value.cons
            (major_mode |> Ecaml.Major_mode.symbol |> Ecaml.Symbol.to_value)
            (Ecaml.Value.of_utf8_bytes style)
        in
        Ecaml.Value.list
          (List.map from_entry major_modes @ Option.to_list other_style)
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "c-default-style") to_sexp to_
        from
  end

  let default_style =
    let open Ecaml.Customization.Wrap in
    "c-default-style" <: Default_style.type_
end

module Comint = struct
  let prompt_read_only =
    let open Ecaml.Customization.Wrap in
    "comint-prompt-read-only" <: bool
end

module Compilation = struct
  let feature = Ecaml.Symbol.intern "compile"

  let scroll_output =
    let type_ =
      let module Type = struct
        type t = [ `Yes | `No | `First_error ]

        let all = [ `Yes; `No; `First_error ]

        let sexp_of_t value =
          let atom =
            match value with
            | `Yes -> "t"
            | `No -> "nil"
            | `First_error -> "first-error"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "compilation-scroll-output" (module Type)
    in
    let open Ecaml.Customization.Wrap in
    "compilation-scroll-output" <: type_

  let context_lines =
    let type_ =
      let to_ value =
        if Ecaml.Value.eq value Ecaml.Value.t then `Never_scroll
        else if Ecaml.Value.is_nil value then `Scroll_when_no_fringe
        else if Ecaml.Value.is_integer value then
          `Number_of_lines (Ecaml.Value.to_int_exn value)
        else assert false
      in
      let from = function
        | `Never_scroll -> Ecaml.Value.t
        | `Scroll_when_no_fringe -> Ecaml.Value.nil
        | `Number_of_lines i -> Ecaml.Value.of_int_exn i
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "compilation-context-lines")
        to_sexp to_ from
    in
    let open Ecaml.Customization.Wrap in
    "compilation-context-lines" <: type_

  let filter_hook =
    let open Ecaml.Hook.Wrap in
    "compilation-filter-hook" <: Ecaml.Hook.Hook_type.Normal_hook

  let compile ?comint command =
    let compile =
      let open Ecaml.Funcall.Wrap in
      "compile" <: string @-> nil_or bool @-> return nil
    in
    compile command comint

  let recompile ?edit_command () =
    let recompile =
      let open Ecaml.Funcall.Wrap in
      "recompile" <: nil_or bool @-> return nil
    in
    recompile edit_command

  let command =
    let open Ecaml.Customization.Wrap in
    "compile-command" <: string

  let read_command =
    let open Ecaml.Funcall.Wrap in
    "compilation-read-command" <: string @-> return string

  module Error_matcher = struct
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

    let type_ =
      let face_symbol = Ecaml.Value.intern "face" in
      let to_ value =
        match Ecaml.Value.to_list_exn ~f:Fun.id value with
        | [] | [ _ ] -> assert false
        | regexp :: file :: others ->
            let line, column, type_, hyperlink, highlights =
              match others with
              | _ :: _ :: _ :: _ :: _ :: _ :: _ -> assert false
              | [] -> (None, None, None, None, None)
              | [ line ] -> (Some line, None, None, None, None)
              | [ line; column ] -> (Some line, Some column, None, None, None)
              | [ line; column; type_ ] ->
                  (Some line, Some column, Some type_, None, None)
              | [ line; column; type_; hyperlink ] ->
                  (Some line, Some column, Some type_, Some hyperlink, None)
              | [ line; column; type_; hyperlink; highlights ] ->
                  ( Some line,
                    Some column,
                    Some type_,
                    Some hyperlink,
                    Some highlights )
            in
            let range_bound value =
              if Ecaml.Value.is_integer value then
                `Subexpression (Ecaml.Value.to_int_exn value)
              else `Function (Ecaml.Function.of_value_exn value)
            in
            let range value =
              if Ecaml.Value.is_nil value then None
              else if not @@ Ecaml.Value.is_cons value then
                Some { start = range_bound value; end_ = None }
              else
                match Ecaml.Value.to_list_exn ~f:Fun.id value with
                | [] | [ _ ] | _ :: _ :: _ :: _ -> assert false
                | [ start; end_ ] ->
                    Some
                      {
                        start = range_bound start;
                        end_ = Some (range_bound end_);
                      }
            in
            let highlight value =
              match Ecaml.Value.to_list_exn ~f:Fun.id value with
              | [] | [ _ ] | _ :: _ :: _ :: _ -> assert false
              | [ subexpression; face ] ->
                  let face, attributes =
                    if
                      not
                      @@ Ecaml.Value.is_cons
                           ~car:(Ecaml.Value.eq face_symbol)
                           face
                    then (Ecaml.Face.of_value_exn face, [])
                    else
                      match Ecaml.Value.to_list_exn ~f:Fun.id face with
                      | [] | [ _ ] | [ _; _ ] | [ _; _; _ ] -> assert false
                      | _ :: face :: (_ :: _ :: _ as attributes) ->
                          ( Ecaml.Face.of_value_exn face,
                            List.map Ecaml.Face.Attribute_and_value.of_value_exn
                              attributes )
                  in
                  (Ecaml.Value.to_int_exn subexpression, face, attributes)
            in
            let file =
              if Ecaml.Value.is_integer file then
                `Subexpression (Ecaml.Value.to_int_exn file, [])
              else if Ecaml.Value.is_function file then
                `Function (Ecaml.Function.of_value_exn file)
              else
                match Ecaml.Value.to_list_exn ~f:Fun.id value with
                | [] -> assert false
                | subexpression :: formats ->
                    `Subexpression
                      ( Ecaml.Value.to_int_exn subexpression,
                        List.map Ecaml.Value.to_utf8_bytes_exn formats )
            in
            let type_ =
              match type_ with
              | None -> Explicit `Error
              | Some type_ -> (
                  if Ecaml.Value.is_nil type_ then Explicit `Error
                  else if Ecaml.Value.is_integer type_ then
                    Explicit
                      (match Ecaml.Value.to_int_exn type_ with
                      | 0 -> `Info
                      | 1 -> `Warning
                      | 2 -> `Error
                      | _ -> assert false)
                  else
                    match
                      Ecaml.Value.to_list_exn ~f:Ecaml.Value.to_int_exn type_
                    with
                    | [] | [ _ ] | _ :: _ :: _ :: _ -> assert false
                    | [ warning_if_match; info_if_match ] ->
                        Conditional { warning_if_match; info_if_match })
            in
            let hyperlink =
              Option.bind hyperlink (fun hyperlink ->
                  Ecaml.Value.Type.of_value_exn
                    (Ecaml.Value.Type.nil_or Ecaml.Value.Type.int)
                    hyperlink)
            in
            let highlights =
              match highlights with
              | None -> []
              | Some highlights ->
                  Ecaml.Value.to_list_exn ~f:highlight highlights
            in
            {
              regexp = Ecaml.Regexp.of_value_exn regexp;
              file;
              line = Option.bind line range;
              column = Option.bind column range;
              type_;
              hyperlink;
              highlights;
            }
      in
      let from { regexp; file; line; column; type_; hyperlink; highlights } =
        let file =
          match file with
          | `Function f -> Ecaml.Function.to_value f
          | `Subexpression (i, []) -> Ecaml.Value.of_int_exn i
          | `Subexpression (i, (_ :: _ as formats)) ->
              Ecaml.Value.list
                (Ecaml.Value.of_int_exn i
                :: List.map Ecaml.Value.of_utf8_bytes formats)
        in
        let from_option from = function
          | None -> Ecaml.Value.nil
          | Some value -> from value
        in
        let from_range_bound = function
          | `Subexpression i -> Ecaml.Value.of_int_exn i
          | `Function f -> Ecaml.Function.to_value f
        in
        let from_range { start; end_ } =
          match end_ with
          | None -> from_range_bound start
          | Some end_ ->
              Ecaml.Value.cons (from_range_bound start) (from_range_bound end_)
        in
        let line = from_option from_range line in
        let column = from_option from_range column in
        let type_ =
          match type_ with
          | Explicit `Error -> Ecaml.Value.of_int_exn 2
          | Explicit `Warning -> Ecaml.Value.of_int_exn 1
          | Explicit `Info -> Ecaml.Value.of_int_exn 0
          | Conditional { warning_if_match; info_if_match } ->
              Ecaml.Value.cons
                (Ecaml.Value.of_int_exn warning_if_match)
                (Ecaml.Value.of_int_exn info_if_match)
        in
        let hyperlink = from_option Ecaml.Value.of_int_exn hyperlink in
        let highlights =
          let from_highlight (subexpression, face, attributes) =
            let face =
              let face = Ecaml.Face.to_value face in
              match attributes with
              | [] -> face
              | _ :: _ ->
                  Ecaml.Value.list
                    (face_symbol :: face
                    :: List.map
                         (function
                           | Ecaml.Face.Attribute_and_value.T (attribute, value)
                             ->
                               Ecaml.Face.Attribute.to_value attribute value)
                         attributes)
            in
            Ecaml.Value.list [ Ecaml.Value.of_int_exn subexpression; face ]
          in
          List.map from_highlight highlights
        in
        Ecaml.Value.list
          ([
             Ecaml.Regexp.to_value regexp; file; line; column; type_; hyperlink;
           ]
          @ highlights)
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "compilation-error-regexp")
        to_sexp to_ from
  end

  let error_regexp_alist =
    let type_ =
      let to_ value =
        if Ecaml.Value.is_symbol value then
          `Symbol (Ecaml.Symbol.of_value_exn value)
        else
          `Error_matcher
            (Ecaml.Value.Type.of_value_exn Error_matcher.type_ value)
      in
      let from = function
        | `Symbol symbol -> Ecaml.Symbol.to_value symbol
        | `Error_matcher error_matcher ->
            Ecaml.Value.Type.to_value Error_matcher.type_ error_matcher
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create
        (Sexplib0.Sexp.Atom "compilation-error-regexp-alist-element") to_sexp
        to_ from
    in
    let open Ecaml.Customization.Wrap in
    "compilation-error-regexp-alist" <: list type_
end

module Debian_el = struct
  let feature = Ecaml.Symbol.intern "debian-el"
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
        else if Ecaml.Value.is_nil value then `Never
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

  let stay_out_of =
    let type_ =
      let to_ value =
        if Ecaml.Value.is_symbol value then
          `Symbol (Ecaml.Symbol.of_value_exn value)
        else `Regexp (Ecaml.Regexp.of_value_exn value)
      in
      let from = function
        | `Symbol s -> Ecaml.Symbol.to_value s
        | `Regexp r -> Ecaml.Regexp.to_value r
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "eglot-stay-out-of") to_sexp
        to_ from
    in
    let open Ecaml.Var.Wrap in
    "eglot-stay-out-of" <: list type_

  let autoshutdown =
    let open Ecaml.Customization.Wrap in
    "eglot-autoshutdown" <: bool

  let ignored_server_capabilities =
    let type_ =
      let module Type = struct
        type t =
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

        let all =
          [
            `Hover_provider;
            `Completion_provider;
            `Signature_help_provider;
            `Definition_provider;
            `Type_definition_provider;
            `Implementation_provider;
            `Declaration_provider;
            `References_provider;
            `Document_highlight_provider;
            `Document_symbol_provider;
            `Workspace_symbol_provider;
            `Code_action_provider;
            `Code_lens_provider;
            `Document_formatting_provider;
            `Document_range_formatting_provider;
            `Document_on_type_formatting_provider;
            `Rename_provider;
            `Document_link_provider;
            `Color_provider;
            `Folding_range_provider;
            `Execute_command_provider;
          ]

        let sexp_of_t value =
          let atom =
            match value with
            | `Code_lens_provider -> ":codeLensProvider"
            | `Declaration_provider -> ":declarationProvider"
            | `Execute_command_provider -> ":executeCommandProvider"
            | `Document_highlight_provider -> ":documentHighlightProvider"
            | `Type_definition_provider -> ":typeDefinitionProvider"
            | `Definition_provider -> ":definitionProvider"
            | `Rename_provider -> ":renameProvider"
            | `Document_symbol_provider -> ":documentSymbolProvider"
            | `Hover_provider -> ":hoverProvider"
            | `Implementation_provider -> ":implementationProvider"
            | `Completion_provider -> ":completionProvider"
            | `Code_action_provider -> ":codeActionProvider"
            | `References_provider -> ":referencesProvider"
            | `Document_formatting_provider -> ":documentFormattingProvider"
            | `Document_range_formatting_provider ->
                ":documentRangeFormattingProvider"
            | `Document_link_provider -> ":documentLinkProvider"
            | `Workspace_symbol_provider -> ":workspaceSymbolProvider"
            | `Folding_range_provider -> ":foldingRangeProvider"
            | `Signature_help_provider -> ":signatureHelpProvider"
            | `Color_provider -> ":colorProvider"
            | `Document_on_type_formatting_provider ->
                ":documentOnTypeFormattingProvider"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "eglot-ignored-server-capabilities" (module Type)
    in
    let open Ecaml.Customization.Wrap in
    "eglot-ignored-server-capabilities" <: list type_

  let ensure =
    let open Ecaml.Funcall.Wrap in
    "eglot-ensure" <: nullary @-> return nil

  let managed_p =
    let open Ecaml.Funcall.Wrap in
    "eglot-managed-p" <: nullary @-> return bool

  let format_buffer =
    let open Ecaml.Funcall.Wrap in
    "eglot-format-buffer" <: nullary @-> return nil
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

module Grep = struct
  let feature = Ecaml.Symbol.intern "grep"

  let read_regexp =
    let open Ecaml.Funcall.Wrap in
    "grep-read-regexp" <: nullary @-> return Ecaml.Regexp.t
end

module Imenu = struct
  module Command = struct
    let imenu = Command.from_string "imenu"
  end
end

module Ispell = struct
  let feature = Ecaml.Symbol.intern "ispell"

  module Command = struct
    let message = Command.from_string "ispell-message"
    let comments_and_strings = Command.from_string "ispell-comments-and-strings"
    let change_dictionary = Command.from_string "ispell-change-dictionary"
    let ispell = Command.from_string "ispell"
  end

  let program_name =
    let open Ecaml.Customization.Wrap in
    "ispell-program-name" <: string

  let change_dictionary ?globally dictionary =
    let change_dictionary =
      let open Ecaml.Funcall.Wrap in
      "ispell-change-dictionary" <: string @-> nil_or bool @-> return nil
    in
    change_dictionary dictionary globally

  let dictionary =
    let open Ecaml.Customization.Wrap in
    "ispell-dictionary" <: nil_or string

  let local_dictionary =
    let local_dictionary =
      let open Ecaml.Buffer_local.Wrap in
      Ecaml.Feature.require feature;
      "ispell-local-dictionary" <: nil_or string
    in
    local_dictionary |> Ecaml.Buffer_local.var |> Customization.from_variable

  let ispell =
    let open Ecaml.Funcall.Wrap in
    "ispell" <: nullary @-> return nil
end

module Scala_mode = struct
  module Indent = struct
    let default_run_on_strategy =
      let type_ =
        let module Type = struct
          type t = [ `Eager | `Operators | `Reluctant ]

          let all = [ `Eager; `Operators; `Reluctant ]

          let sexp_of_t value =
            let atom =
              match value with
              | `Eager -> "scala-indent:eager-strategy"
              | `Operators -> "scala-indent:operator-strategy"
              | `Reluctant -> "scala-indent:reluctant-strategy"
            in
            Sexplib0.Sexp.Atom atom
        end in
        Value.Type.enum "require-final-newline" (module Type)
      in
      let open Ecaml.Customization.Wrap in
      "scala-indent:default-run-on-strategy" <: type_
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

  let line_function =
    let open Ecaml.Var.Wrap in
    "indent-line-function" <: Ecaml.Function.type_

  let relative =
    "indent-relative" |> Ecaml.Symbol.intern |> Ecaml.Function.of_symbol
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
      "package-refresh-contents" <: nil_or bool @-> return nil
    in
    refresh_contents async

  let selected_packages =
    let open Ecaml.Customization.Wrap in
    "package-selected-packages" <: list Ecaml.Symbol.type_

  let initialize ?no_activate () =
    let initialize =
      let open Ecaml.Funcall.Wrap in
      "package-initialize" <: nil_or bool @-> return nil
    in
    initialize no_activate

  let install_selected_packages ?no_confirm () =
    let install_selected_packages =
      let open Ecaml.Funcall.Wrap in
      "package-install-selected-packages" <: nil_or bool @-> return string
    in
    ignore (install_selected_packages no_confirm)
end

module Proof_general = struct
  module Coq = struct
    let one_command_per_line =
      let open Ecaml.Customization.Wrap in
      "coq-one-command-per-line" <: bool
  end

  let splash_enable =
    let open Ecaml.Customization.Wrap in
    "proof-splash-enable" <: bool

  let three_window_mode_policy =
    let type_ =
      let module Type = struct
        type t = [ `Smart | `Horizontal | `Hybrid | `Vertical ]

        let all = [ `Smart; `Horizontal; `Hybrid; `Vertical ]

        let sexp_of_t value =
          let atom =
            match value with
            | `Smart -> "smart"
            | `Horizontal -> "horizontal"
            | `Hybrid -> "hybrid"
            | `Vertical -> "vertical"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "proof-three-window-mode-policy" (module Type)
    in
    let open Ecaml.Customization.Wrap in
    "proof-three-window-mode-policy" <: type_
end

module Reftex = struct
  type auctex_plugins = {
    supply_labels_in_new_sections_and_environments : bool;
    supply_arguments_for_macros_like_label : bool;
    supply_arguments_for_macros_like_ref : bool;
    supply_arguments_for_macros_like_cite : bool;
    supply_arguments_for_macros_like_index : bool;
  }

  let plug_into_auctex =
    let type_ =
      let to_ value =
        if Ecaml.Value.eq value Ecaml.Value.t then
          {
            supply_labels_in_new_sections_and_environments = true;
            supply_arguments_for_macros_like_label = true;
            supply_arguments_for_macros_like_ref = true;
            supply_arguments_for_macros_like_cite = true;
            supply_arguments_for_macros_like_index = true;
          }
        else
          match Ecaml.Value.to_list_exn ~f:Ecaml.Value.to_bool value with
          | [ _ ]
          | [ _; _ ]
          | [ _; _; _ ]
          | [ _; _; _; _ ]
          | _ :: _ :: _ :: _ :: _ :: _ :: _ ->
              assert false
          | [] ->
              {
                supply_labels_in_new_sections_and_environments = false;
                supply_arguments_for_macros_like_label = false;
                supply_arguments_for_macros_like_ref = false;
                supply_arguments_for_macros_like_cite = false;
                supply_arguments_for_macros_like_index = false;
              }
          | [
           supply_labels_in_new_sections_and_environments;
           supply_arguments_for_macros_like_label;
           supply_arguments_for_macros_like_ref;
           supply_arguments_for_macros_like_cite;
           supply_arguments_for_macros_like_index;
          ] ->
              {
                supply_labels_in_new_sections_and_environments;
                supply_arguments_for_macros_like_label;
                supply_arguments_for_macros_like_ref;
                supply_arguments_for_macros_like_cite;
                supply_arguments_for_macros_like_index;
              }
      in
      let from
          {
            supply_labels_in_new_sections_and_environments;
            supply_arguments_for_macros_like_label;
            supply_arguments_for_macros_like_ref;
            supply_arguments_for_macros_like_cite;
            supply_arguments_for_macros_like_index;
          } =
        [
          supply_labels_in_new_sections_and_environments;
          supply_arguments_for_macros_like_label;
          supply_arguments_for_macros_like_ref;
          supply_arguments_for_macros_like_cite;
          supply_arguments_for_macros_like_index;
        ]
        |> List.map Ecaml.Value.of_bool
        |> Ecaml.Value.list
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "reftex-plug-into-AUCTeX")
        to_sexp to_ from
    in
    let open Ecaml.Customization.Wrap in
    "reftex-plug-into-AUCTeX" <: type_

  let enable_partial_scans =
    let open Ecaml.Customization.Wrap in
    "reftex-enable-partial-scans" <: bool

  let save_parse_info =
    let open Ecaml.Customization.Wrap in
    "reftex-save-parse-info" <: bool

  let use_multiple_selection_buffers =
    let open Ecaml.Customization.Wrap in
    "reftex-use-multiple-selection-buffers" <: bool
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

module Tuareg = struct
  let interactive_read_only_input =
    let open Ecaml.Customization.Wrap in
    "tuareg-interactive-read-only-input" <: bool
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

  let root_dir =
    let open Ecaml.Funcall.Wrap in
    "vc-root-dir" <: nullary @-> return (nil_or string)

  module Git = struct
    let feature = Ecaml.Symbol.intern "vc-git"

    let grep ?files ?dir regexp =
      let grep =
        let open Ecaml.Funcall.Wrap in
        "vc-git-grep"
        <: Ecaml.Regexp.t @-> nil_or string @-> nil_or string @-> return nil
      in
      grep regexp files dir
  end
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

module Window = struct
  let set_buffer_start_and_point ?start ?point ~buffer window =
    let set_buffer_start_and_point =
      let open Ecaml.Funcall.Wrap in
      "set-window-buffer-start-and-point"
      <: Ecaml.Window.type_ @-> Ecaml.Buffer.type_
         @-> nil_or Ecaml.Position.type_
         @-> nil_or Ecaml.Position.type_
         @-> return nil
    in
    set_buffer_start_and_point window buffer start point
end

module Winner = struct
  let feature = Ecaml.Symbol.intern "winner"

  module Command = struct
    let undo () =
      Ecaml.Feature.require feature;
      Command.from_string "winner-undo"
  end
end
