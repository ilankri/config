let cleanup_list_numbers =
  let open Ecaml.Funcall.Wrap in
  "markdown-cleanup-list-numbers" <: nullary @-> return nil

let command =
  let open Ecaml.Customization.Wrap in
  "markdown-command" <: string

let asymmetric_header =
  let open Ecaml.Customization.Wrap in
  "markdown-asymmetric-header" <: bool

let fontify_code_blocks_natively =
  let open Ecaml.Customization.Wrap in
  "markdown-fontify-code-blocks-natively" <: bool
