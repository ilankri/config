let bind_magit_project_status =
  let open Ecaml.Var.Wrap in
  "magit-bind-magit-project-status" <: bool

let commit_show_diff =
  let open Ecaml.Customization.Wrap in
  "magit-commit-show-diff" <: bool

let define_global_key_bindings =
  let open Ecaml.Customization.Wrap in
  "magit-define-global-key-bindings" <: bool
