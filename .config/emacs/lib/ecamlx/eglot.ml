let feature = Ecaml.Symbol.intern "eglot"

module Command = struct
  let code_actions () =
    Ecaml.Feature.require feature;
    Command.from_string "eglot-code-actions"

  let rename () =
    Ecaml.Feature.require feature;
    Command.from_string "eglot-rename"
end

let stay_out_of =
  let type_ =
    let to_ value =
      if Ecaml.Value.is_symbol value then
        `Symbol (Ecaml.Symbol.of_value_exn value)
      else `Regexp (Ecaml.Regexp.of_value_exn value)
    in
    let from = function
      | `Symbol s -> Ecaml.Symbol.to_value s
      | `Regexp r -> Ecaml.Regexp.to_value r
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "eglot-stay-out-of") to_sexp to_
      from
  in
  let open Ecaml.Var.Wrap in
  "eglot-stay-out-of" <: list type_

let autoshutdown =
  let open Ecaml.Customization.Wrap in
  "eglot-autoshutdown" <: bool

let ignored_server_capabilities =
  let type_ =
    let module Type = struct
      type t =
        [ `Hover_provider
        | `Completion_provider
        | `Signature_help_provider
        | `Definition_provider
        | `Type_definition_provider
        | `Implementation_provider
        | `Declaration_provider
        | `References_provider
        | `Document_highlight_provider
        | `Document_symbol_provider
        | `Workspace_symbol_provider
        | `Code_action_provider
        | `Code_lens_provider
        | `Document_formatting_provider
        | `Document_range_formatting_provider
        | `Document_on_type_formatting_provider
        | `Rename_provider
        | `Document_link_provider
        | `Color_provider
        | `Folding_range_provider
        | `Execute_command_provider ]

      let all =
        [
          `Hover_provider;
          `Completion_provider;
          `Signature_help_provider;
          `Definition_provider;
          `Type_definition_provider;
          `Implementation_provider;
          `Declaration_provider;
          `References_provider;
          `Document_highlight_provider;
          `Document_symbol_provider;
          `Workspace_symbol_provider;
          `Code_action_provider;
          `Code_lens_provider;
          `Document_formatting_provider;
          `Document_range_formatting_provider;
          `Document_on_type_formatting_provider;
          `Rename_provider;
          `Document_link_provider;
          `Color_provider;
          `Folding_range_provider;
          `Execute_command_provider;
        ]

      let sexp_of_t value =
        let atom =
          match value with
          | `Code_lens_provider -> ":codeLensProvider"
          | `Declaration_provider -> ":declarationProvider"
          | `Execute_command_provider -> ":executeCommandProvider"
          | `Document_highlight_provider -> ":documentHighlightProvider"
          | `Type_definition_provider -> ":typeDefinitionProvider"
          | `Definition_provider -> ":definitionProvider"
          | `Rename_provider -> ":renameProvider"
          | `Document_symbol_provider -> ":documentSymbolProvider"
          | `Hover_provider -> ":hoverProvider"
          | `Implementation_provider -> ":implementationProvider"
          | `Completion_provider -> ":completionProvider"
          | `Code_action_provider -> ":codeActionProvider"
          | `References_provider -> ":referencesProvider"
          | `Document_formatting_provider -> ":documentFormattingProvider"
          | `Document_range_formatting_provider ->
              ":documentRangeFormattingProvider"
          | `Document_link_provider -> ":documentLinkProvider"
          | `Workspace_symbol_provider -> ":workspaceSymbolProvider"
          | `Folding_range_provider -> ":foldingRangeProvider"
          | `Signature_help_provider -> ":signatureHelpProvider"
          | `Color_provider -> ":colorProvider"
          | `Document_on_type_formatting_provider ->
              ":documentOnTypeFormattingProvider"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "eglot-ignored-server-capabilities" (module Type)
  in
  let open Ecaml.Customization.Wrap in
  "eglot-ignored-server-capabilities" <: list type_

let ensure =
  let open Ecaml.Funcall.Wrap in
  "eglot-ensure" <: nullary @-> return nil

let managed_p =
  let open Ecaml.Funcall.Wrap in
  "eglot-managed-p" <: nullary @-> return bool

let format_buffer =
  let open Ecaml.Funcall.Wrap in
  "eglot-format-buffer" <: nullary @-> return nil
