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

module Language = struct
  type t = { major_mode : Ecaml.Major_mode.t; id : string option }

  let make ?id major_mode = { major_mode; id }

  let type_ =
    let language_id = Ecaml.Value.intern ":language-id" in
    let rec to_ value =
      if Ecaml.Value.is_symbol value then
        [
          {
            major_mode =
              Ecaml.Major_mode.find_or_wrap_existing
                (Position.to_lexing_position ~__POS__)
                (Ecaml.Symbol.of_value_exn value);
            id = None;
          };
        ]
      else
        match Ecaml.Value.to_list_exn ~f:Fun.id value with
        | ([] | [ _ ] | [ _; _ ] | _ :: _ :: _ :: _ :: _) as major_modes ->
            List.concat_map to_ major_modes
        | [ major_mode; maybe_language_id; maybe_id ] as major_modes ->
            if not @@ Ecaml.Value.eq maybe_language_id language_id then
              List.concat_map to_ major_modes
            else
              [
                {
                  major_mode =
                    Ecaml.Major_mode.find_or_wrap_existing
                      (Position.to_lexing_position ~__POS__)
                      (Ecaml.Symbol.of_value_exn major_mode);
                  id = Some (Ecaml.Value.to_utf8_bytes_exn maybe_id);
                };
              ]
    in
    let from value =
      Ecaml.Value.list
        (List.map
           (fun { major_mode; id } ->
             let major_mode :> Ecaml.Value.t =
               Ecaml.Major_mode.symbol major_mode
             in
             match id with
             | None -> major_mode
             | Some id ->
                 Ecaml.Value.list
                   [ major_mode; language_id; Ecaml.Value.of_utf8_bytes id ])
           value)
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create
      (Sexplib0.Sexp.Atom "eglot-server-programs-languages") to_sexp to_ from

  module Server = struct
    type t =
      | Program of {
          name : string;
          args : string list;
          initialization_options :
            [ `List of Ecaml.Value.t list | `Function of Ecaml.Function.t ]
            option;
        }
      | Program_with_auto_port of {
          name : string;
          args_before_auto_port : string list;
          args_after_auto_port : string list;
        }
      | Host of { name : string; port : int; tcp_args : string list }
      | Class of { name : Ecaml.Symbol.t; init_args : Ecaml.Value.t list }

    let make_program ?(args = []) ?initialization_options name =
      Program { name; args; initialization_options }

    let type_ =
      let initialization_options_keyword =
        Ecaml.Value.intern ":initializationOptions"
      in
      let auto_port = Ecaml.Value.intern ":autoport" in
      let to_ value =
        let split_on_separator ~separator elements =
          let _, elements_before_separator, elements_after_separator =
            List.fold_left
              (fun ( is_after_separator,
                     elements_before_separator,
                     elements_after_separator ) element ->
                if is_after_separator then
                  ( is_after_separator,
                    elements_before_separator,
                    elements_after_separator @ [ element ] )
                else if Ecaml.Value.eq element separator then
                  (true, elements_before_separator, elements_after_separator)
                else
                  ( is_after_separator,
                    elements_before_separator @ [ element ],
                    elements_after_separator ))
              (false, [], []) elements
          in
          (elements_before_separator, elements_after_separator)
        in
        if Ecaml.Value.is_cons ~car:Ecaml.Value.is_symbol value then
          Class
            {
              name = value |> Ecaml.Value.car_exn |> Ecaml.Symbol.of_value_exn;
              init_args =
                Ecaml.Value.to_list_exn ~f:Fun.id (Ecaml.Value.cdr_exn value);
            }
        else
          let value = Ecaml.Value.to_list_exn ~f:Fun.id value in
          if List.exists (Ecaml.Value.eq auto_port) value then
            match value with
            | [] | [ _ ] -> assert false
            | name :: args ->
                let args_before_auto_port, args_after_auto_port =
                  split_on_separator ~separator:auto_port args
                in
                Program_with_auto_port
                  {
                    name = Ecaml.Value.to_utf8_bytes_exn name;
                    args_before_auto_port =
                      List.map Ecaml.Value.to_utf8_bytes_exn
                        args_before_auto_port;
                    args_after_auto_port =
                      List.map Ecaml.Value.to_utf8_bytes_exn
                        args_after_auto_port;
                  }
          else if List.exists Ecaml.Value.is_integer value then
            match value with
            | [] | [ _ ] -> assert false
            | name :: port :: tcp_args ->
                Host
                  {
                    name = Ecaml.Value.to_utf8_bytes_exn name;
                    port = Ecaml.Value.to_int_exn port;
                    tcp_args = List.map Ecaml.Value.to_utf8_bytes_exn tcp_args;
                  }
          else
            match value with
            | [] -> assert false
            | name :: args ->
                let args, initialization_options =
                  split_on_separator ~separator:initialization_options_keyword
                    args
                in
                let initialization_options =
                  match initialization_options with
                  | _ :: _ :: _ -> assert false
                  | [] -> None
                  | [ initialization_options ] ->
                      Some
                        (if Ecaml.Value.is_function initialization_options then
                           `Function
                             (Ecaml.Function.of_value_exn initialization_options)
                         else
                           `List
                             (Ecaml.Value.to_list_exn ~f:Fun.id
                                initialization_options))
                in
                Program
                  {
                    name = Ecaml.Value.to_utf8_bytes_exn name;
                    args = List.map Ecaml.Value.to_utf8_bytes_exn args;
                    initialization_options;
                  }
      in
      let from = function
        | Program { name; args; initialization_options } ->
            let initialization_options =
              match initialization_options with
              | None -> []
              | Some (`List initialization_options) ->
                  [
                    initialization_options_keyword;
                    Ecaml.Value.list initialization_options;
                  ]
              | Some (`Function initialization_options) ->
                  [
                    initialization_options_keyword;
                    (initialization_options :> Ecaml.Value.t);
                  ]
            in
            Ecaml.Value.list
              (Ecaml.Value.of_utf8_bytes name
               :: List.map Ecaml.Value.of_utf8_bytes args
              @ initialization_options)
        | Program_with_auto_port
            { name; args_before_auto_port; args_after_auto_port } ->
            Ecaml.Value.list
              (Ecaml.Value.of_utf8_bytes name
               :: List.map Ecaml.Value.of_utf8_bytes args_before_auto_port
              @ auto_port
                :: List.map Ecaml.Value.of_utf8_bytes args_after_auto_port)
        | Host { name; port; tcp_args } ->
            Ecaml.Value.list
              (Ecaml.Value.of_utf8_bytes name
              :: Ecaml.Value.of_int_exn port
              :: List.map Ecaml.Value.of_utf8_bytes tcp_args)
        | Class { name; init_args } ->
            Ecaml.Value.cons
              (name :> Ecaml.Value.t)
              (Ecaml.Value.list init_args)
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create
        (Sexplib0.Sexp.Atom "eglot-server-programs-server") to_sexp to_ from
  end
end

let server_programs =
  let type_ =
    let to_ value =
      if Ecaml.Value.is_function value then
        `Function (Ecaml.Function.of_value_exn value)
      else
        `Language_server
          (Ecaml.Value.Type.of_value_exn Language.Server.type_ value)
    in
    let from = function
      | `Function f -> Ecaml.Function.to_value f
      | `Language_server language_server ->
          Ecaml.Value.Type.to_value Language.Server.type_ language_server
    in
    let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
    Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "eglot-server-programs-program")
      to_sexp to_ from
  in
  let open Ecaml.Var.Wrap in
  Ecaml.Feature.require feature;
  "eglot-server-programs" <: list (tuple Language.type_ type_)

let connect_timeout =
  let open Ecaml.Customization.Wrap in
  "eglot-connect-timeout" <: nil_or int

let ensure =
  let open Ecaml.Funcall.Wrap in
  "eglot-ensure" <: nullary @-> return nil

let managed_p =
  let open Ecaml.Funcall.Wrap in
  "eglot-managed-p" <: nullary @-> return bool

let format_buffer =
  let open Ecaml.Funcall.Wrap in
  "eglot-format-buffer" <: nullary @-> return nil
