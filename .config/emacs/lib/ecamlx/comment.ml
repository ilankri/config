let multi_line =
  let open Ecaml.Customization.Wrap in
  "comment-multi-line" <: bool

let start =
  let open Ecaml.Var.Wrap in
  "comment-start" <: string

let end_ =
  let open Ecaml.Var.Wrap in
  "comment-end" <: string
