let library_name = "my"
let prefix_name name = Format.sprintf "%s-%s" library_name name

let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecamlx.defun ~name:(prefix_name name) ~__POS__ ?docstring ?define_keys
    ?obsoletes ?should_profile ?interactive ?disabled ?evil_config ~returns f

let hook_defun
    ?(name = Ecaml.Symbol.name @@ Ecaml.Symbol.gensym ~prefix:"hook-f" ())
    ~__POS__ ?docstring ?should_profile ~hook_type ~returns f =
  Ecamlx.Hook.Function.create ~name:(prefix_name name) ~__POS__ ?docstring
    ?should_profile ~hook_type ~returns f

let user_key key = Ecaml.Key_sequence.create_exn @@ Format.sprintf "C-c %s" key
let global_set_key key command = Ecamlx.global_set_key (user_key key) command
let local_set_key key command = Ecamlx.local_set_key (user_key key) command

let set_prefix_key ?(local = false) ~prefix key command =
  let key = Format.sprintf "%s %s" prefix key in
  (if local then local_set_key else global_set_key) key command

let set_ispell_key ?local key command =
  set_prefix_key ?local ~prefix:"o" key command

let set_eglot_key ?local key command =
  set_prefix_key ?local ~prefix:"l" key command

let _ansi_term =
  defun ~name:"ansi-term" ~__POS__
    ~returns:(Ecaml.Returns.Returns_deferred Ecaml.Buffer.type_)
    ~interactive:Ecaml.Defun.Interactive.Raw_prefix
    (let open Ecaml.Defun.Let_syntax in
    Ecaml.Defun.optional_with_default "arg" false Ecaml.Defun.bool
    >>| fun arg ->
    let default_buffer_name = "terminal" in
    let new_buffer_name =
      if arg then
        Ecaml.Completing.read ~history:Ecaml.Minibuffer.history
          ~collection:(Ecaml.Completing.Collection.create_elisp [])
          ~default:default_buffer_name ~prompt:"Name: " ()
      else Async_kernel.return default_buffer_name
    in
    Async_kernel.Deferred.map new_buffer_name ~f:(fun new_buffer_name ->
        Ecamlx.Term.ansi_term ~new_buffer_name
          (Option.value
             ~default:(Ecaml.Customization.value Ecamlx.shell_file_name)
             (Ecaml.System.getenv ~var:"ESHELL"))))

module Command = struct
  let from_string name =
    prefix_name name |> Ecaml.Value.intern |> Ecaml.Command.of_value_exn

  let ispell_en () = from_string "ispell-en"
  let ispell_fr () = from_string "ispell-fr"
  let compile () = from_string "compile"
  let indent_buffer () = from_string "indent-buffer"
  let kill_buffer () = from_string "kill-current-buffer"
  let git_grep () = from_string "git-grep"
  let transpose_windows () = from_string "transpose-windows"
  let ansi_term () = from_string "ansi-term"
end

let _scala3_end_column =
  defun ~name:"scala3-end-column" ~__POS__
    ~returns:
      (Ecaml.Returns.Returns (Ecaml.Value.Type.nil_or Ecaml.Value.Type.int))
    (let open Ecaml.Defun.Let_syntax in
    return () >>| fun () ->
    Option.map
      (fun column -> column |> String.trim |> int_of_string |> succ)
      (Ecamlx.Regexp.match_string 3))

module Function = struct
  let from_string name =
    prefix_name name |> Ecaml.Symbol.intern |> Ecaml.Function.of_symbol

  let scala3_end_column () = from_string "scala3-end-column"
end

let prefix_by_user_emacs_directory =
  let open Ecaml.Funcall.Wrap in
  prefix_name "prefix-by-user-emacs-directory" <: string @-> return string

let init_package_archives () =
  Ecaml.Feature.require Ecamlx.Package.feature;
  Ecamlx.Customization.set_value Ecamlx.Package.archives
    (Ecaml.Customization.value Ecamlx.Package.archives
    @ [ ("melpa-stable", "https://stable.melpa.org/packages/") ])

let _init_packages =
  defun ~name:"init-packages" ~__POS__
    ~returns:(Ecaml.Returns.Returns Ecaml.Value.Type.unit)
    (let open Ecaml.Defun.Let_syntax in
    return () >>| init_package_archives >>| fun () ->
    Ecamlx.Package.refresh_contents ())

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

let git_commit_setup_hook_f =
  hook_defun ~name:"git-commit-setup-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Diff_mode.refine (Some Ecamlx.Diff_mode.Refine.Navigation);
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Whitespace.action [];
      Ecaml.Minor_mode.enable Ecamlx.Minor_mode.diff)

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
  let cleanup_list_numbers =
    hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit Ecamlx.Markdown_mode.cleanup_list_numbers
  in
  hook_defun ~name:"markdown-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecaml.Hook.add ~buffer_local:true ~where:Ecaml.Hook.Where.End
        Ecaml.Hook.before_save cleanup_list_numbers)

let message_mode_hook_f =
  hook_defun ~name:"message-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Whitespace.action [];
      set_ispell_key ~local:true "o" Ecamlx.Ispell.Command.message)

let init =
  let open Ecaml.Defun.Let_syntax in
  return () >>| fun () ->
  let init =
    let open Ecaml.Funcall.Wrap in
    "my-init" <: nullary @-> Ecaml.Funcall.Wrap.return nil
  in
  let enable_auto_fill =
    hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        Ecaml.Minor_mode.enable Ecamlx.Minor_mode.auto_fill)
  in
  let ansi_color_compilation_filter =
    hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit Ecamlx.Ansi_color.compilation_filter
  in
  let eglot_ensure =
    hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit Ecamlx.Eglot.ensure
  in
  let eglot_maybe_format_buffer =
    hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        if Ecamlx.Eglot.managed_p () then Ecamlx.Eglot.format_buffer ())
  in
  let eglot_format_buffer_before_save =
    hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        Ecaml.Hook.add ~buffer_local:true ~where:Ecaml.Hook.Where.End
          Ecaml.Hook.before_save eglot_maybe_format_buffer)
  in
  let enable_flyspell =
    hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        Ecaml.Minor_mode.enable Ecamlx.Minor_mode.flyspell)
  in
  let ispell_change_to_fr_dictionary =
    hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        Ecamlx.Ispell.change_dictionary "fr_FR")
  in
  Ecaml.Feature.require @@ Ecaml.Symbol.intern "my0";
  init_package_archives ();
  Ecamlx.Customization.set_value Ecamlx.Package.selected_packages
    (List.map Ecaml.Symbol.intern
       [
         "magit";
         "git-commit";
         "reason-mode";
         "debian-el";
         "csv-mode";
         "rust-mode";
         "go-mode";
         "markdown-mode";
         "scala-mode";
         "gnu-elpa-keyring-update";
         "eglot";
         "yaml-mode";
         "tuareg";
         "ocp-indent";
         "dune";
         "git-modes";
         "dockerfile-mode";
         "auctex";
       ]);
  Ecamlx.Package.initialize ();

  (* Ensure that packages are installed.  *)
  Ecamlx.Package.install_selected_packages ();

  init ();

  (* Eglot *)
  List.iter
    (fun (module Major_mode : Ecaml.Major_mode.S_with_lazy_keymap) ->
      Ecaml.Hook.add
        (Ecaml.Hook.major_mode_hook Major_mode.major_mode)
        eglot_ensure)
    [ (module Ecamlx.Major_mode.Scala); (module Ecaml.Major_mode.Tuareg) ];
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecaml.Major_mode.Prog.major_mode)
    eglot_format_buffer_before_save;
  Ecamlx.Customization.set_value Ecamlx.Eglot.autoshutdown true;
  Ecamlx.Customization.set_value Ecamlx.Eglot.ignored_server_capabilities
    [ `Document_highlight_provider ];
  Ecaml.Var.set_default_value Ecamlx.Eglot.stay_out_of
    [ `Symbol (Ecaml.Symbol.intern "flymake") ];

  (* Semantic *)
  Ecamlx.Customization.set_value Ecamlx.Semantic.default_submodes
    (Ecamlx.Semantic.Submode.global_stickyfunc
    :: Ecaml.Customization.value Ecamlx.Semantic.default_submodes);
  Ecaml.Minor_mode.enable Ecamlx.Minor_mode.semantic;

  (* Ispell *)

  (* Use hunspell instead of aspell because hunspell has a better French
     support. *)
  Ecamlx.Customization.set_value Ecamlx.Ispell.program_name "hunspell";

  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecaml.Major_mode.Text.major_mode)
    enable_flyspell;

  (* Switch to French dictionary when writing mails or LaTeX files.  *)
  List.iter
    (fun hook -> Ecaml.Hook.add hook ispell_change_to_fr_dictionary)
    [
      Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Message.major_mode;
      Ecamlx.Auctex.Latex.mode_hook;
    ];

  (* Filling *)
  Ecamlx.Customization.set_value Ecamlx.Current_buffer.fill_column 72;
  Ecamlx.Customization.set_value Ecamlx.Comment.multi_line true;
  Ecamlx.Customization.set_value Ecamlx.Fill.nobreak_predicate
    (Ecamlx.Fill.french_nobreak_p
    :: Ecaml.Customization.value Ecamlx.Fill.nobreak_predicate);

  (* auto-fill-mode is only enabled in CC mode (and not in all program
     modes) because it seems to be the only program mode that properly
     deals with auto-fill. *)
  List.iter
    (fun hook -> Ecaml.Hook.add hook enable_auto_fill)
    [
      Ecaml.Hook.major_mode_hook Ecaml.Major_mode.Text.major_mode;
      Ecamlx.Cc_mode.common_hook;
    ];

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

  (* Compilation *)
  Ecamlx.Customization.set_value Ecamlx.Compilation.scroll_output `First_error;
  Ecamlx.Customization.set_value Ecamlx.Compilation.context_lines
    (`Number_of_lines 0);
  Ecaml.Hook.add Ecamlx.Compilation.filter_hook ansi_color_compilation_filter;
  Ecaml.Feature.require Ecamlx.Compilation.feature;
  Ecamlx.Customization.set_value Ecamlx.Compilation.error_regexp_alist
    (List.map
       (fun error_matcher -> `Error_matcher error_matcher)
       [
         {
           Ecamlx.Compilation.Error_matcher.regexp =
             Ecaml.Regexp.of_pattern
               "^\\[error\\] \\(.+\\):\\([0-9]+\\):\\([0-9]+\\):";
           file = `Subexpression (1, []);
           line =
             Some
               {
                 Ecamlx.Compilation.Error_matcher.start = `Subexpression 2;
                 end_ = None;
               };
           column =
             Some
               {
                 Ecamlx.Compilation.Error_matcher.start = `Subexpression 3;
                 end_ = None;
               };
           type_ = Ecamlx.Compilation.Error_matcher.Explicit `Error;
           hyperlink = None;
           highlights = [];
         };
         {
           Ecamlx.Compilation.Error_matcher.regexp =
             Ecaml.Regexp.of_pattern
               "^\\[warn\\] \\(.+\\):\\([0-9]+\\):\\([0-9]+\\):";
           file = `Subexpression (1, []);
           line =
             Some
               {
                 Ecamlx.Compilation.Error_matcher.start = `Subexpression 2;
                 end_ = None;
               };
           column =
             Some
               {
                 Ecamlx.Compilation.Error_matcher.start = `Subexpression 3;
                 end_ = None;
               };
           type_ = Ecamlx.Compilation.Error_matcher.Explicit `Warning;
           hyperlink = None;
           highlights = [];
         };
         (* sbt with Scala 2 *)
         {
           Ecamlx.Compilation.Error_matcher.regexp =
             Ecaml.Regexp.of_pattern
               ".*Error: \\(.+\\):\\([0-9]+\\):\\([0-9]+\\)";
           file = `Subexpression (1, []);
           line =
             Some
               {
                 Ecamlx.Compilation.Error_matcher.start = `Subexpression 2;
                 end_ = None;
               };
           column =
             Some
               {
                 Ecamlx.Compilation.Error_matcher.start =
                   `Function (Function.scala3_end_column ());
                 end_ = None;
               };
           type_ = Ecamlx.Compilation.Error_matcher.Explicit `Error;
           hyperlink = None;
           highlights = [];
         };
         {
           Ecamlx.Compilation.Error_matcher.regexp =
             Ecaml.Regexp.of_pattern
               ".*Warning: \\(.+\\):\\([0-9]+\\):\\([0-9]+\\)";
           file = `Subexpression (1, []);
           line =
             Some
               {
                 Ecamlx.Compilation.Error_matcher.start = `Subexpression 2;
                 end_ = None;
               };
           column =
             Some
               {
                 Ecamlx.Compilation.Error_matcher.start =
                   `Function (Function.scala3_end_column ());
                 end_ = None;
               };
           type_ = Ecamlx.Compilation.Error_matcher.Explicit `Warning;
           hyperlink = None;
           highlights = [];
         };
         (* Scala 3 *)
       ]
    @ Ecaml.Customization.value Ecamlx.Compilation.error_regexp_alist);

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

  (* Magit *)
  Ecaml.Feature.require Ecamlx.Git_commit.feature;
  Ecaml.Var.set_default_value Ecamlx.Magit.bind_magit_project_status false;
  Ecamlx.Customization.set_value Ecamlx.Git_commit.summary_max_length
    (Ecaml.Customization.value Ecamlx.Current_buffer.fill_column);
  Ecamlx.Customization.set_value Ecamlx.Magit.commit_show_diff false;
  Ecamlx.Customization.set_value Ecamlx.Magit.define_global_key_bindings false;
  Ecaml.Hook.add Ecamlx.Git_commit.setup_hook git_commit_setup_hook_f;

  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Diff.major_mode)
    diff_mode_hook_f;
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Conf.major_mode)
    indent_tabs_mode_on;
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Message.major_mode)
    message_mode_hook_f;
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Csv.major_mode)
    csv_mode_hook_f;
  Ecamlx.Custom.load_theme "modus-operandi";

  Ecamlx.Customization.set_value Ecamlx.Dired.completion_ignored_extensions
    ([
       "auto/";
       ".prv/";
       "_build/";
       "_opam/";
       "target/";
       "_client/";
       "_deps/";
       "_server/";
       ".sass-cache/";
       ".d";
       ".native";
       ".byte";
       ".bc";
       ".exe";
       ".pdf";
       ".out";
       ".fls";
       ".synctex.gz";
       ".rel";
       ".unq";
       ".tns";
       ".emacs.desktop";
       ".emacs.desktop.lock";
       "_region_.tex";
     ]
    @ Ecaml.Customization.value Ecamlx.Dired.completion_ignored_extensions);

  (* Hack to open files like Makefile.local or Dockerfile.test with the
     right mode. *)
  Ecaml.Var.set_default_value Ecaml.Auto_mode_alist.auto_mode_alist
    (Ecaml.Var.default_value_exn Ecaml.Auto_mode_alist.auto_mode_alist
    @ [
        {
          Ecaml.Auto_mode_alist.Entry.filename_match =
            Ecaml.Regexp.of_pattern "\\.[^/]*\\'";
          function_ = None;
          delete_suffix_and_recur = true;
        };
      ]);

  Ecaml.Auto_mode_alist.add
    (List.map
       (fun (pattern, major_mode) ->
         {
           Ecaml.Auto_mode_alist.Entry.filename_match =
             Ecaml.Regexp.of_pattern pattern;
           function_ = Some (Ecaml.Major_mode.symbol major_mode);
           delete_suffix_and_recur = false;
         })
       [
         ("README\\'", Ecaml.Major_mode.Text.major_mode);
         ("bash-fc\\'", Ecamlx.Major_mode.Sh.major_mode);
         ("\\.bash_aliases\\'", Ecamlx.Major_mode.Sh.major_mode);
         ("\\.dockerignore\\'", Ecamlx.Major_mode.Gitignore.major_mode);
         ("\\.ml[ly]\\'", Ecaml.Major_mode.Tuareg.major_mode);
         ("\\.ocp-indent\\'", Ecamlx.Major_mode.Conf_unix.major_mode);
         ("_tags\\'", Ecamlx.Major_mode.Conf_colon.major_mode);
         ("\\.merlin\\'", Ecamlx.Major_mode.Conf_space.major_mode);
         ("\\.mrconfig\\'", Ecamlx.Major_mode.Conf_unix.major_mode);
         ("\\.eml\\'", Ecamlx.Major_mode.Message.major_mode);
       ]);

  (* Miscellaneous settings *)
  Ecaml.Var.set_default_value Ecamlx.Novice.disabled_command_function None;
  Ecamlx.Customization.set_value Ecamlx.Startup.inhibit_startup_screen true;
  Ecamlx.Customization.set_value Ecamlx.mode_line_compact `Long;
  Ecamlx.Customization.set_value Ecamlx.Custom.file
    (Some (prefix_by_user_emacs_directory ".custom.el"));
  Ecamlx.Customization.set_value Ecamlx.Files.auto_mode_case_fold false;
  Ecamlx.Customization.set_value Ecamlx.Startup.initial_buffer_choice
    (Some
       (`Function
         (Ecaml.Function.of_value_exn @@ Ecaml.Command.to_value
        @@ Command.ansi_term ())));
  Ecamlx.Customization.set_value Ecamlx.track_eol true;
  Ecamlx.Customization.set_value Ecamlx.Minibuffer.completions_format
    `One_column;
  Ecamlx.Customization.set_value Ecamlx.Minibuffer.enable_recursive_minibuffers
    true;
  Ecamlx.Customization.set_value Ecamlx.Files.view_read_only true;
  Ecamlx.Customization.set_value Ecamlx.Diff_mode.default_read_only true;
  Ecamlx.Customization.set_value Ecamlx.Eldoc.echo_area_use_multiline_p `Never;
  Ecamlx.Customization.set_value Ecamlx.Comint.prompt_read_only true;
  Ecamlx.Customization.set_value Ecamlx.Term.buffer_maximum_size 0;
  Ecamlx.Customization.set_value Ecamlx.Vc.follow_symlinks `Follow_link;
  Ecamlx.Customization.set_value Ecamlx.Vc.command_messages true;
  Ecamlx.Customization.set_value Ecamlx.Files.require_final_newline `Save;
  Ecamlx.Customization.set_value Ecamlx.Current_buffer.scroll_up_aggressively
    (Some 0.);
  Ecamlx.Customization.set_value Ecamlx.Current_buffer.scroll_down_aggressively
    (Some 0.);
  Ecamlx.Customization.set_value Ecamlx.Indent.tabs_mode false;

  (* Custom global key bindings *)
  global_set_key "a" Ecamlx.Find_file.Command.get_other_file;
  global_set_key "c" (Command.compile ());
  global_set_key "b" Ecamlx.Windmove.Command.left;
  global_set_key "f" Ecamlx.Windmove.Command.right;
  global_set_key "h" Ecamlx.Man.Command.man;
  global_set_key "i" (Command.indent_buffer ());
  global_set_key "j" Ecamlx.Browse_url.Command.browse_url;
  global_set_key "k" (Command.kill_buffer ());
  set_eglot_key "a" (Ecamlx.Eglot.Command.code_actions ());
  set_eglot_key "r" (Ecamlx.Eglot.Command.rename ());
  global_set_key "m" Ecamlx.Imenu.Command.imenu;
  global_set_key "n" Ecamlx.Windmove.Command.down;
  set_ispell_key "c" Ecamlx.Ispell.Command.comments_and_strings;
  set_ispell_key "d" Ecamlx.Ispell.Command.change_dictionary;
  set_ispell_key "e" (Command.ispell_en ());
  set_ispell_key "f" (Command.ispell_fr ());
  set_ispell_key "o" Ecamlx.Ispell.Command.ispell;
  global_set_key "p" Ecamlx.Windmove.Command.up;
  global_set_key "s" (Command.git_grep ());
  global_set_key "t" (Command.transpose_windows ());
  global_set_key "u" (Ecamlx.Winner.Command.undo ());
  global_set_key "x" Ecamlx.Command.switch_to_completions;
  global_set_key "v" (Command.ansi_term ());
  global_set_key "w" Ecamlx.Whitespace.Command.cleanup;
  global_set_key "y" Ecamlx.Command.blink_matching_open;

  List.iter Ecaml.Minor_mode.disable
    [
      Ecamlx.Minor_mode.tool_bar;
      Ecamlx.Minor_mode.menu_bar;
      Ecamlx.Minor_mode.scroll_bar;
    ];
  List.iter Ecaml.Minor_mode.enable
    [
      Ecamlx.Minor_mode.column_number;
      Ecamlx.Minor_mode.global_subword;
      Ecamlx.Minor_mode.delete_selection;
      Ecamlx.Minor_mode.electric_indent;
      Ecamlx.Minor_mode.electric_pair;
      Ecamlx.Minor_mode.show_paren;
      Ecamlx.Minor_mode.savehist;
      Ecamlx.Minor_mode.winner;
      Ecamlx.Minor_mode.fido_vertical;
      Ecamlx.Minor_mode.minibuffer_depth_indicate;
      Ecamlx.Minor_mode.global_auto_revert;
    ];

  Ecamlx.Frame.toggle_fullscreen ();

  (* Emacs server *)
  Ecamlx.Server.start ()

let () =
  defun ~name:"init" ~__POS__
    ~returns:(Ecaml.Returns.Returns Ecaml.Value.Type.unit) init;
  Ecaml.provide @@ Ecaml.Symbol.intern library_name
