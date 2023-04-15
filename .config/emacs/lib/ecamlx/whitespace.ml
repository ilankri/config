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
                  (Ecaml.Major_mode.find_or_wrap_existing
                     (Position.to_lexing_position ~__POS__))
                  except
              in
              All { except }
            else
              let major_modes =
                List.map
                  (Ecaml.Major_mode.find_or_wrap_existing
                     (Position.to_lexing_position ~__POS__))
                  major_modes
              in
              Only major_modes
    in

    let from = function
      | All { except = [] } -> Ecaml.Value.t
      | All { except = _ :: _ as except } ->
          Ecaml.Value.list
            (not_
            :: (List.map Ecaml.Major_mode.symbol except :> Ecaml.Value.t list))
      | Only major_modes ->
          Ecaml.Value.list
            (List.map Ecaml.Major_mode.symbol major_modes :> Ecaml.Value.t list)
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "whitespace-global-modes")
      to_sexp to_ from
end

let global_modes =
  let open Ecaml.Customization.Wrap in
  "whitespace-global-modes" <: Global_modes.type_
