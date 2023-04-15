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
                         (Position.to_lexing_position ~__POS__)
                         (Ecaml.Symbol.of_value_exn major_mode))
                in
                let style =
                  value |> Ecaml.Value.cdr_exn |> Ecaml.Value.to_utf8_bytes_exn
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
