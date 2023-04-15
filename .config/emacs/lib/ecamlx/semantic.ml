module Submode = struct
  type t = Ecaml.Minor_mode.t

  let global_stickyfunc = Minor_mode.make "global-semantic-stickyfunc-mode"

  let type_ =
    let to_ value = value |> Ecaml.Value.prin1_to_string |> Minor_mode.make in
    let from minor_mode =
      (Ecaml.Minor_mode.function_name minor_mode :> Ecaml.Value.t)
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "semantic-submodes") to_sexp to_
      from
end

let default_submodes =
  let open Ecaml.Customization.Wrap in
  "semantic-default-submodes" <: list Submode.type_
