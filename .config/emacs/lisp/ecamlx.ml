type position = string * int * int * int

let position ~__POS__:(pos_fname, pos_lnum, pos_cnum, _) =
  { Lexing.pos_fname; pos_lnum; pos_cnum; pos_bol = 0 }

let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecaml.defun (Ecaml.Symbol.intern name) (position ~__POS__)
    ~docstring:(Option.value ~default:"None" docstring)
    ?define_keys ?obsoletes ?should_profile ?interactive ?disabled ?evil_config
    (Ecaml.Returns.Returns returns) f

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

module Current_buffer = struct
  let set_buffer_local variable value =
    let variable = Ecaml.Customization.var variable in
    Ecaml.Current_buffer.set_buffer_local
      (Ecaml.Buffer_local.wrap_existing ~make_buffer_local_always:true
         (Ecaml.Var.symbol variable)
         (Ecaml.Var.type_ variable))
      value
end

module Hook = struct
  module Function = struct
    let create ~name ~__POS__ ?docstring ?should_profile ~hook_type ~returns f =
      Ecaml.Hook.Function.create (Ecaml.Symbol.intern name) (position ~__POS__)
        ~docstring:(Option.value ~default:"None" docstring)
        ?should_profile ~hook_type (Ecaml.Returns.Returns returns) f
  end
end

module Major_mode = struct
  module Conf =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "conf-mode"
           (position ~__POS__))

  module Csv =
    (val Ecaml.Major_mode.wrap_existing_with_lazy_keymap "csv-mode"
           (position ~__POS__))
end

module Custom = struct
  let load_theme ?no_confirm ?no_enable theme =
    let load_theme =
      let open Ecaml.Funcall.Wrap in
      "load-theme"
      <: Ecaml.Symbol.t @-> nil_or bool @-> nil_or bool @-> return nil
    in
    load_theme (Ecaml.Symbol.intern theme) no_confirm no_enable
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

module Whitespace = struct
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
end
