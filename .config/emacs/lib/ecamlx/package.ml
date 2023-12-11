let feature = Ecaml.Symbol.intern "package"

let archives =
  let open Ecaml.Customization.Wrap in
  "package-archives" <: list (tuple string string)

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
    "package-install-selected-packages" <: nil_or bool @-> return nil
  in
  install_selected_packages no_confirm

module Vc = struct
  module Package_specification = struct
    type t = {
      url : string;
      branch : string option;
      lisp_dir : string option;
      main_file : string option;
      doc : string option;
      vc_backend : Ecaml.Symbol.t option;
    }

    let make ?branch ?lisp_dir ?main_file ?doc ?vc_backend url =
      { url; branch; lisp_dir; main_file; doc; vc_backend }

    let type_ =
      let url_keyword = Ecaml.Value.intern ":url" in
      let branch_keyword = Ecaml.Value.intern ":branch" in
      let lisp_dir_keyword = Ecaml.Value.intern ":lisp-dir" in
      let main_file_keyword = Ecaml.Value.intern ":main-file" in
      let doc_keyword = Ecaml.Value.intern ":doc" in
      let vc_backend_keyword = Ecaml.Value.intern ":vc-backend" in
      let to_ value : t =
        let _, url, branch, lisp_dir, main_file, doc, vc_backend =
          let decode_property
              (key, url, branch, lisp_dir, main_file, doc, vc_backend) value =
            match key with
            | None ->
                let key =
                  if Ecaml.Value.eq value url_keyword then `Url
                  else if Ecaml.Value.eq value branch_keyword then `Branch
                  else if Ecaml.Value.eq value lisp_dir_keyword then `Lisp_dir
                  else if Ecaml.Value.eq value main_file_keyword then `Main_file
                  else if Ecaml.Value.eq value doc_keyword then `Doc
                  else if Ecaml.Value.eq value vc_backend_keyword then
                    `Vc_backend
                  else assert false
                in
                (Some key, url, branch, lisp_dir, main_file, doc, vc_backend)
            | Some key ->
                let url, branch, lisp_dir, main_file, doc, vc_backend =
                  let optional_value ~to_ value =
                    if Ecaml.Value.is_nil value then None else Some (to_ value)
                  in
                  let optional_string value =
                    optional_value ~to_:Ecaml.Value.to_utf8_bytes_exn value
                  in
                  match key with
                  | `Url ->
                      ( Some (Ecaml.Value.to_utf8_bytes_exn value),
                        branch,
                        lisp_dir,
                        main_file,
                        doc,
                        vc_backend )
                  | `Branch ->
                      ( url,
                        optional_string value,
                        lisp_dir,
                        main_file,
                        doc,
                        vc_backend )
                  | `Lisp_dir ->
                      ( url,
                        branch,
                        optional_string value,
                        main_file,
                        doc,
                        vc_backend )
                  | `Main_file ->
                      ( url,
                        branch,
                        lisp_dir,
                        optional_string value,
                        doc,
                        vc_backend )
                  | `Doc ->
                      ( url,
                        branch,
                        lisp_dir,
                        main_file,
                        optional_string value,
                        vc_backend )
                  | `Vc_backend ->
                      ( url,
                        branch,
                        lisp_dir,
                        main_file,
                        doc,
                        optional_value ~to_:Ecaml.Symbol.of_value_exn value )
                in
                (None, url, branch, lisp_dir, main_file, doc, vc_backend)
          in
          List.fold_left decode_property
            (None, None, None, None, None, None, None)
            (Ecaml.Value.to_list_exn ~f:Fun.id value)
        in
        { url = Option.get url; branch; lisp_dir; main_file; doc; vc_backend }
      in
      let from { url; branch; lisp_dir; main_file; doc; vc_backend } =
        let optional_property ~from ~key = function
          | None -> []
          | Some value -> [ key; from value ]
        in
        Ecaml.Value.list
          ([ url_keyword; Ecaml.Value.of_utf8_bytes url ]
          @ List.concat_map
              (fun (key, value) ->
                optional_property ~from:Ecaml.Value.of_utf8_bytes ~key value)
              [
                (branch_keyword, branch);
                (lisp_dir_keyword, lisp_dir);
                (main_file_keyword, main_file);
                (doc_keyword, doc);
              ]
          @ optional_property ~from:Ecaml.Symbol.to_value
              ~key:vc_backend_keyword vc_backend)
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create
        (Sexplib0.Sexp.Atom "package-vc-package-specification") to_sexp to_ from
  end

  let selected_packages =
    let type_ =
      let to_ value =
        if Ecaml.Value.is_string value then
          `Version (Ecaml.Value.to_utf8_bytes_exn value)
        else
          `Package_specification
            (Ecaml.Value.Type.of_value_exn Package_specification.type_ value)
      in
      let from = function
        | `Version version -> Ecaml.Value.of_utf8_bytes version
        | `Package_specification package_specification ->
            Ecaml.Value.Type.to_value Package_specification.type_
              package_specification
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create
        (Sexplib0.Sexp.Atom "package-vc-selected-packages-package-specification")
        to_sexp to_ from
    in
    let open Ecaml.Customization.Wrap in
    "package-vc-selected-packages"
    <: list (tuple Ecaml.Symbol.type_ (nil_or type_))

  let install_selected_packages =
    let open Ecaml.Funcall.Wrap in
    "package-vc-install-selected-packages" <: nullary @-> return nil
end
