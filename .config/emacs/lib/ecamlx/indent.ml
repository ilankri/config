let tabs_mode =
  let open Ecaml.Customization.Wrap in
  "indent-tabs-mode" <: bool

let line_function =
  let open Ecaml.Var.Wrap in
  "indent-line-function" <: Ecaml.Function.type_

let relative =
  "indent-relative" |> Ecaml.Symbol.intern |> Ecaml.Function.of_symbol
