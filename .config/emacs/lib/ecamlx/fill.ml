let nobreak_predicate =
  let open Ecaml.Customization.Wrap in
  "fill-nobreak-predicate" <: list Ecaml.Function.t

let french_nobreak_p =
  "fill-french-nobreak-p" |> Ecaml.Symbol.intern |> Ecaml.Function.of_symbol
