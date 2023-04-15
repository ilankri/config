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
