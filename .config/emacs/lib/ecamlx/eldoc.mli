val echo_area_use_multiline_p :
  [ `Never
  | `Always
  | `Truncate_sym_name_if_fit
  | `Fraction_of_frame_height of float
  | `Number_of_lines of int ]
  Ecaml.Customization.t
