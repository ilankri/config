let set_variable ?comment variable value_ =
  let customize_set_variable =
    let open Ecaml.Funcall.Wrap in
    "customize-set-variable"
    <: Ecaml.Symbol.type_ @-> value @-> nil_or string @-> return nil
  in
  let variable = Ecaml.Customization.var variable in
  customize_set_variable
    (Ecaml.Var.symbol variable)
    (Ecaml.Value.Type.to_value variable.Ecaml.Var.type_ value_)
    comment

let from_variable variable =
  let open Ecaml.Customization.Wrap in
  variable |> Ecaml.Var.symbol |> Ecaml.Symbol.name <: Ecaml.Var.type_ variable
