let disabled_command_function =
  let open Ecaml.Var.Wrap in
  "disabled-command-function" <: nil_or Ecaml.Function.t
