let library_name = "my"
let prefix_name name = Format.sprintf "%s-%s" library_name name

let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecamlx.defun ~name:(prefix_name name) ~__POS__ ?docstring ?define_keys
    ?obsoletes ?should_profile ?interactive ?disabled ?evil_config ~returns f

let hook_defun ~name ~__POS__ ?docstring ?should_profile ~hook_type ~returns f =
  Ecamlx.Hook.Function.create ~name:(prefix_name name) ~__POS__ ?docstring
    ?should_profile ~hook_type ~returns f

let indent_tabs_mode_on =
  hook_defun ~name:"indent-tabs-mode-on" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Indent.tabs_mode true)

let try_smerge =
  hook_defun ~name:"try-smerge" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecaml.Feature.require Ecamlx.Smerge_mode.feature;
      Ecaml.Current_buffer.save_excursion Ecaml.Sync_or_async.Sync @@ fun () ->
      Ecaml.Point.goto_min ();
      if
        Ecaml.Point.search_forward_regexp
          (Ecaml.Var.default_value_exn Ecamlx.Smerge_mode.begin_re)
      then Ecaml.Minor_mode.enable Ecamlx.Minor_mode.smerge)

let csv_mode_hook_f =
  hook_defun ~name:"csv-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Whitespace.style
        (List.filter
           (fun x -> x <> Ecamlx.Whitespace.Style.Lines)
           (Ecaml.Customization.value Ecamlx.Whitespace.style));
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Whitespace.action [])

let diff_mode_hook_f =
  hook_defun ~name:"diff-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_buffer_local
        Ecamlx.Current_buffer.inhibit_read_only true;
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Files.view_read_only false;
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Whitespace.action [])

let markdown_mode_hook_f =
  hook_defun ~name:"markdown-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecaml.Hook.add ~buffer_local:true ~where:Ecaml.Hook.Where.End
        Ecaml.Hook.before_save
        (Ecamlx.Hook.Function.create ~name:String.empty ~__POS__
           ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
           ~returns:Ecaml.Value.Type.unit
           Ecamlx.Markdown_mode.cleanup_list_numbers))

let init =
  let init =
    let open Ecaml.Funcall.Wrap in
    "my-init" <: nullary @-> return nil
  in
  Ecaml.Feature.require @@ Ecaml.Symbol.intern "my0";
  init ();

  (* Whitespace *)
  Ecaml.Minor_mode.enable Ecamlx.Minor_mode.global_whitespace;

  (* Do not display spaces, tabs and newlines marks.  *)
  Ecamlx.Customization.set_value Ecamlx.Whitespace.style
    (List.filter
       (fun x ->
         not
         @@ List.mem x
              [
                Ecamlx.Whitespace.Style.Tabs;
                Ecamlx.Whitespace.Style.Spaces;
                Ecamlx.Whitespace.Style.Newline;
                Ecamlx.Whitespace.Style.Space_mark;
                Ecamlx.Whitespace.Style.Tab_mark;
                Ecamlx.Whitespace.Style.Newline_mark;
              ])
       (Ecaml.Customization.value Ecamlx.Whitespace.style));

  Ecamlx.Customization.set_value Ecamlx.Whitespace.action
    [ Ecamlx.Whitespace.Action.Auto_cleanup ];

  (* Turn off whitespace-mode in Dired-like buffers.  *)
  Ecamlx.Customization.set_value Ecamlx.Whitespace.global_modes
    (Ecamlx.Whitespace.Global_modes.All
       {
         except =
           [
             Ecaml.Major_mode.Dired.major_mode;
             Ecamlx.Major_mode.Archive.major_mode;
             Ecamlx.Major_mode.Git_rebase.major_mode;
           ];
       });

  (* Markdown *)
  Ecamlx.Customization.set_value Ecamlx.Markdown_mode.command "pandoc";
  Ecamlx.Customization.set_value Ecamlx.Markdown_mode.asymmetric_header true;
  Ecamlx.Customization.set_value
    Ecamlx.Markdown_mode.fontify_code_blocks_natively true;
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Markdown.major_mode)
    markdown_mode_hook_f;

  (* Enable smerge-mode when necessary.  *)
  Ecaml.Hook.add Ecamlx.Hook.find_file try_smerge;

  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Diff.major_mode)
    diff_mode_hook_f;
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Conf.major_mode)
    indent_tabs_mode_on;
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Csv.major_mode)
    csv_mode_hook_f;
  Ecamlx.Custom.load_theme "modus-operandi";

  (* Emacs server *)
  Ecamlx.Server.start ();

  Ecaml.Defun.return ()

let () =
  defun ~name:"init" ~__POS__ ~returns:Ecaml.Value.Type.unit init;
  Ecaml.provide @@ Ecaml.Symbol.intern library_name
