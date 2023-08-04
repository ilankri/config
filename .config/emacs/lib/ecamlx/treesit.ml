let feature = Ecaml.Symbol.intern "treesit"

let ready_p ?quiet lang =
  let ready_p =
    let quiet_type =
      let module Type = struct
        type t = [ `Yes | `No | `Message ]

        let all = [ `Yes; `No; `Message ]

        let sexp_of_t value =
          let atom =
            match value with
            | `Yes -> "t"
            | `No -> "nil"
            | `Message -> "message"
          in
          Sexplib0.Sexp.Atom atom
      end in
      Value.Type.enum "treesit-ready-p-quiet" (module Type)
    in
    let open Ecaml.Funcall.Wrap in
    "treesit-ready-p" <: Ecaml.Symbol.t @-> nil_or quiet_type @-> return bool
  in
  ready_p lang quiet

module Language_source = struct
  type t = {
    url : string;
    revision : string option;
    source_dir : string option;
    cc : string option;
    c_plus_plus : string option;
  }

  let make ?revision ?source_dir ?cc ?c_plus_plus url =
    { url; revision; source_dir; cc; c_plus_plus }

  let type_ =
    let to_ value =
      let url, revision, source_dir, cc, c_plus_plus =
        match Ecaml.Value.to_list_exn ~f:Fun.id value with
        | [] | _ :: _ :: _ :: _ :: _ :: _ :: _ -> assert false
        | [ url ] -> (url, None, None, None, None)
        | [ url; revision ] -> (url, Some revision, None, None, None)
        | [ url; revision; source_dir ] ->
            (url, Some revision, Some source_dir, None, None)
        | [ url; revision; source_dir; cc ] ->
            (url, Some revision, Some source_dir, Some cc, None)
        | [ url; revision; source_dir; cc; c_plus_plus ] ->
            (url, Some revision, Some source_dir, Some cc, Some c_plus_plus)
      in
      let to_string_option value =
        if Ecaml.Value.is_nil value then None
        else Some (Ecaml.Value.to_utf8_bytes_exn value)
      in
      {
        url = Ecaml.Value.to_utf8_bytes_exn url;
        revision = Option.bind revision to_string_option;
        source_dir = Option.bind source_dir to_string_option;
        cc = Option.bind cc to_string_option;
        c_plus_plus = Option.bind c_plus_plus to_string_option;
      }
    in
    let from { url; revision; source_dir; cc; c_plus_plus } =
      let from_string_option = function
        | None -> Ecaml.Value.nil
        | Some value -> Ecaml.Value.of_utf8_bytes value
      in
      Ecaml.Value.list
        (Ecaml.Value.of_utf8_bytes url
        :: List.map from_string_option [ revision; source_dir; cc; c_plus_plus ]
        )
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "treesit-language-source")
      to_sexp to_ from
end

let language_source_alist =
  let open Ecaml.Var.Wrap in
  "treesit-language-source-alist"
  <: list (tuple Ecaml.Symbol.type_ Language_source.type_)

let install_language_grammar =
  let open Ecaml.Funcall.Wrap in
  "treesit-install-language-grammar" <: Ecaml.Symbol.type_ @-> return nil
