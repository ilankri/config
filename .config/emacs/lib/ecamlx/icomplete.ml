let minibuffer_setup_hook =
  let open Ecaml.Hook.Wrap in
  "icomplete-minibuffer-setup-hook" <: Ecaml.Hook.Hook_type.Normal_hook
