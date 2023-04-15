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
