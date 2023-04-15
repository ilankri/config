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
