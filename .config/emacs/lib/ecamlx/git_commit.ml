let feature = Ecaml.Symbol.intern "git-commit"

let summary_max_length =
  let open Ecaml.Customization.Wrap in
  "git-commit-summary-max-length" <: int

let setup_hook =
  let open Ecaml.Hook.Wrap in
  "git-commit-setup-hook" <: Ecaml.Hook.Hook_type.Normal_hook
