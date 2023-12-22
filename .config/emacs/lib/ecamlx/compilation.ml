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

module Command = struct
  let recompile = Command.from_string "recompile"
end

module Error_matcher = struct
  type subexpression = int

  type type_ =
    | Explicit of [ `Error | `Warning | `Info ]
    | Conditional of {
        warning_if_match : subexpression;
        info_if_match : subexpression;
      }

  type range = {
    start : [ `Subexpression of subexpression | `Function of Ecaml.Function.t ];
    end_ :
      [ `Subexpression of subexpression | `Function of Ecaml.Function.t ] option;
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
            | Some highlights -> Ecaml.Value.to_list_exn ~f:highlight highlights
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
        ([ Ecaml.Regexp.to_value regexp; file; line; column; type_; hyperlink ]
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
        `Error_matcher (Ecaml.Value.Type.of_value_exn Error_matcher.type_ value)
    in
    let from = function
      | `Symbol symbol -> Ecaml.Symbol.to_value symbol
      | `Error_matcher error_matcher ->
          Ecaml.Value.Type.to_value Error_matcher.type_ error_matcher
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create
      (Sexplib0.Sexp.Atom "compilation-error-regexp-alist-element") to_sexp to_
      from
  in
  let open Ecaml.Customization.Wrap in
  "compilation-error-regexp-alist" <: list type_
