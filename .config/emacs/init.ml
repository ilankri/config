let user_key key = Format.sprintf "C-c %s" key
let global_set_key key command = Ecamlx.Keymap.global_set (user_key key) command
let local_set_key key command = Ecamlx.Keymap.local_set (user_key key) command

let set_prefix_key ?(local = false) ~prefix key command =
  let key = Format.sprintf "%s %s" prefix key in
  (if local then local_set_key else global_set_key) key command

let set_ispell_key ?local key command =
  set_prefix_key ?local ~prefix:"o" key command

let set_eglot_key ?local key command =
  set_prefix_key ?local ~prefix:"l" key command

module Function = struct
  let scala3_end_column () =
    Ecamlx.Defun.lambda ~__POS__
      ~returns:
        (Ecaml.Returns.Returns (Ecaml.Value.Type.nil_or Ecaml.Value.Type.int))
      (let open Ecaml.Defun.Let_syntax in
      return () >>| fun () ->
      Option.map
        (fun column -> column |> String.trim |> int_of_string |> succ)
        (Ecamlx.Regexp.match_string 3))

  let prompt_file_for_auto_insert filename =
    let open Async_kernel.Deferred.Let_syntax in
    Ecaml.Completing.read ~history:Ecaml.Minibuffer.history
      ~collection:
        (Ecaml.Completing.Collection.create_elisp
           [ "c"; "java"; "latex"; "ocaml" ])
      ~require_match:Ecaml.Completing.Require_match.True ~prompt:"Type: " ()
    >>| fun type_ ->
    Ecaml.Point.insert_file_contents_exn
      (Format.sprintf "%s%s/%s"
         (Ecaml.Customization.value Ecamlx.Auto_insert.directory)
         type_ filename)

  let makefile_auto_insert () =
    Ecamlx.Defun.lambda ~__POS__
      ~returns:(Ecaml.Returns.Returns_deferred Ecaml.Value.Type.unit)
      (let open Ecaml.Defun.Let_syntax in
      return () >>| fun () -> prompt_file_for_auto_insert "Makefile")

  let gitignore_auto_insert () =
    Ecamlx.Defun.lambda ~__POS__
      ~returns:(Ecaml.Returns.Returns_deferred Ecaml.Value.Type.unit)
      (let open Ecaml.Defun.Let_syntax in
      return () >>| fun () -> prompt_file_for_auto_insert "gitignore")
end

let prefix_by_user_emacs_directory file =
  Ecaml.Var.default_value_exn Ecamlx.User.emacs_directory ^ file

let c_trad_comment_on () =
  Ecamlx.Current_buffer.set_buffer_local Ecamlx.Comment.start "/* ";
  Ecamlx.Current_buffer.set_buffer_local Ecamlx.Comment.end_ " */"

let indent_tabs_mode_on =
  My.hook_defun ~name:"indent-tabs-mode-on" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Indent.tabs_mode true)

let try_smerge =
  My.hook_defun ~name:"try-smerge" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecaml.Feature.require Ecamlx.Smerge_mode.feature;
      Ecaml.Current_buffer.save_excursion Ecaml.Sync_or_async.Sync @@ fun () ->
      Ecaml.Point.goto_min ();
      if
        Ecaml.Point.search_forward_regexp
          (Ecaml.Var.default_value_exn Ecamlx.Smerge_mode.begin_re)
      then Ecaml.Minor_mode.enable Ecamlx.Minor_mode.smerge)

let scala_mode_hook_f =
  My.hook_defun ~name:"scala-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      (* Hacks for Scala 3 *)
      Ecamlx.Current_buffer.set_buffer_local Ecamlx.Indent.line_function
        Ecamlx.Indent.relative;
      Ecaml.Hook.remove_symbol ~buffer_local:true Ecamlx.Hook.post_self_insert
        (Ecaml.Symbol.intern "scala-indent:indent-on-special-words");

      c_trad_comment_on ())

let csv_mode_hook_f =
  My.hook_defun ~name:"csv-mode-hook-f" ~__POS__
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
  My.hook_defun ~name:"git-commit-setup-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Diff_mode.refine (Some Ecamlx.Diff_mode.Refine.Navigation);
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Whitespace.action [];
      Ecaml.Minor_mode.enable Ecamlx.Minor_mode.diff)

let diff_mode_hook_f =
  My.hook_defun ~name:"diff-mode-hook-f" ~__POS__
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
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit Ecamlx.Markdown_mode.cleanup_list_numbers
  in
  My.hook_defun ~name:"markdown-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecaml.Hook.add ~buffer_local:true ~where:Ecaml.Hook.Where.End
        Ecaml.Hook.before_save cleanup_list_numbers)

let message_mode_hook_f =
  My.hook_defun ~name:"message-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Whitespace.action [];
      set_ispell_key ~local:true "o" Ecamlx.Ispell.Command.message)

let c_initialization_hook_f =
  My.hook_defun ~name:"c-initialization-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Customization.set_variable Ecamlx.Cc_mode.default_style
        {
          (Ecaml.Customization.standard_value Ecamlx.Cc_mode.default_style) with
          Ecamlx.Cc_mode.Default_style.other = Some "linux";
        })

let tuareg_mode_hook_f =
  My.hook_defun ~name:"tuareg-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () -> Ecamlx.Keymap.local_unset "C-c C-h")

let icomplete_minibuffer_setup_hook_f =
  My.hook_defun ~name:"icomplete-minibuffer-setup-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_customization_buffer_local
        Ecamlx.Minibuffer.completion_auto_help `Never)

let typst_mode_hook_f =
  My.hook_defun ~name:"typst-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () -> Ecamlx.Keymap.local_unset "M-TAB")

let init () =
  let enable_auto_fill =
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        Ecaml.Minor_mode.enable Ecamlx.Minor_mode.auto_fill)
  in
  let ansi_color_compilation_filter =
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit Ecamlx.Ansi_color.compilation_filter
  in
  let eglot_ensure =
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit Ecamlx.Eglot.ensure
  in
  let eglot_maybe_format_buffer =
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        if Ecamlx.Eglot.managed_p () then Ecamlx.Eglot.format_buffer ())
  in
  let eglot_format_buffer_before_save =
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        Ecaml.Hook.add ~buffer_local:true ~where:Ecaml.Hook.Where.End
          Ecaml.Hook.before_save eglot_maybe_format_buffer)
  in
  let enable_flyspell =
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        Ecaml.Minor_mode.enable Ecamlx.Minor_mode.flyspell)
  in
  let ispell_change_to_fr_dictionary =
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        Ecamlx.Ispell.change_dictionary "fr_FR")
  in
  let c_trad_comment_on =
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit c_trad_comment_on
  in
  let enable_latex_minor_modes =
    My.hook_defun ~__POS__ ~hook_type:Ecaml.Hook.Hook_type.Normal_hook
      ~returns:Ecaml.Value.Type.unit (fun () ->
        List.iter Ecaml.Minor_mode.enable
          [
            Ecamlx.Auctex.Tex.Minor_mode.pdf;
            Ecamlx.Auctex.Latex.Minor_mode.math;
            Ecamlx.Auctex.Tex.Minor_mode.source_correlate;
            Ecamlx.Minor_mode.reftex;
          ])
  in
  Ecaml.Var.set_default_value Ecamlx.Load.prefer_newer true;
  Ecamlx.Customization.set_variable Ecamlx.Custom.file
    (Some (prefix_by_user_emacs_directory ".custom.el"));
  My.init_package_archives ();
  Ecamlx.Customization.set_variable Ecamlx.Package.selected_packages
    (List.map Ecaml.Symbol.intern
       [
         "magit";
         "git-commit";
         "reason-mode";
         "debian-el";
         "csv-mode";
         "markdown-mode";
         "scala-mode";
         "gnu-elpa-keyring-update";
         "tuareg";
         "dune";
         "git-modes";
         "auctex";
         "proof-general";
       ]);
  Ecamlx.Customization.set_variable Ecamlx.Package.Vc.selected_packages
    (List.map
       (fun (name, spec) ->
         (Ecaml.Symbol.intern name, Some (`Package_specification spec)))
       [
         ( "typst-ts-mode",
           Ecamlx.Package.Vc.Package_specification.make
             "https://git.sr.ht/~meow_king/typst-ts-mode" );
       ]);
  Ecamlx.Package.initialize ();

  (* Ensure that packages are installed.  *)
  Ecamlx.Package.install_selected_packages ();
  Ecamlx.Package.Vc.install_selected_packages ();

  Ecaml.Feature.require Ecamlx.Debian_el.feature;

  (* Tree-sitter *)
  Ecaml.Feature.require Ecamlx.Treesit.feature;
  Ecaml.Var.set_default_value Ecamlx.Treesit.language_source_alist
    [
      ( Ecaml.Symbol.intern "rust",
        Ecamlx.Treesit.Language_source.make
          "https://github.com/tree-sitter/tree-sitter-rust.git" );
      ( Ecaml.Symbol.intern "go",
        Ecamlx.Treesit.Language_source.make
          "https://github.com/tree-sitter/tree-sitter-go.git" );
      ( Ecaml.Symbol.intern "gomod",
        Ecamlx.Treesit.Language_source.make
          "https://github.com/camdencheek/tree-sitter-go-mod.git" );
      ( Ecaml.Symbol.intern "yaml",
        Ecamlx.Treesit.Language_source.make
          "https://github.com/ikatyang/tree-sitter-yaml.git" );
      ( Ecaml.Symbol.intern "dockerfile",
        Ecamlx.Treesit.Language_source.make
          "https://github.com/camdencheek/tree-sitter-dockerfile.git" );
      ( Ecaml.Symbol.intern "typst",
        Ecamlx.Treesit.Language_source.make
          "https://github.com/uben0/tree-sitter-typst.git" );
    ];
  List.iter Ecamlx.Treesit.install_language_grammar
    (List.filter
       (Fun.negate @@ Ecamlx.Treesit.ready_p ~quiet:`Yes)
       (List.map fst
          (Ecaml.Var.default_value_exn Ecamlx.Treesit.language_source_alist)));
  List.iter
    (fun (lang, _) ->
      let lang = Ecaml.Symbol.name lang in
      if lang <> "gomod" then
        Ecaml.Feature.require @@ Ecaml.Symbol.intern
        @@ Format.sprintf "%s-ts-mode" lang)
    (Ecaml.Var.default_value_exn Ecamlx.Treesit.language_source_alist);

  (* Eglot *)
  List.iter
    (fun (module Major_mode : Ecaml.Major_mode.S_with_lazy_keymap) ->
      Ecaml.Hook.add
        (Ecaml.Hook.major_mode_hook Major_mode.major_mode)
        eglot_ensure)
    [
      (module Ecamlx.Major_mode.Scala);
      (module Ecaml.Major_mode.Tuareg);
      (module Ecamlx.Major_mode.Sh);
      (module Ecamlx.Major_mode.Typst);
    ];
  Ecaml.Var.set_default_value Ecamlx.Eglot.server_programs
    (( [ Ecamlx.Eglot.Language.make Ecamlx.Major_mode.Typst.major_mode ],
       `Language_server (Ecamlx.Eglot.Language.Server.make_program "typst-lsp")
     )
    :: Ecaml.Var.default_value_exn Ecamlx.Eglot.server_programs);
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecaml.Major_mode.Prog.major_mode)
    eglot_format_buffer_before_save;
  Ecamlx.Customization.set_variable Ecamlx.Eglot.autoshutdown true;
  Ecamlx.Customization.set_variable Ecamlx.Eglot.ignored_server_capabilities
    [ `Document_highlight_provider ];
  Ecamlx.Customization.set_variable Ecamlx.Eglot.connect_timeout None;
  Ecaml.Var.set_default_value Ecamlx.Eglot.stay_out_of
    [ `Symbol (Ecaml.Symbol.intern "flymake") ];

  (* Auto-insert *)

  (* Prompt the user for the appropriate Makefile type to insert.  *)
  Ecamlx.Auto_insert.define ~description:"Makefile"
    (`Regexp (Ecaml.Regexp.of_pattern "[Mm]akefile\\'"))
    (`Function (Function.makefile_auto_insert ()));

  Ecamlx.Auto_insert.define ~description:".gitignore file"
    (`Regexp (Ecaml.Regexp.of_pattern ".gitignore\\'"))
    (`Function (Function.gitignore_auto_insert ()));
  Ecamlx.Customization.set_variable Ecamlx.Auto_insert.directory
    (prefix_by_user_emacs_directory "insert/");
  Ecamlx.Auto_insert.define (`Major_mode Ecamlx.Major_mode.Latex.major_mode)
    (`File
      (Ecaml.Customization.standard_value Ecamlx.Auto_insert.directory
      ^ "latex/preamble.tex"));
  Ecaml.Minor_mode.enable Ecamlx.Minor_mode.auto_insert;

  (* Semantic *)
  Ecamlx.Customization.set_variable Ecamlx.Semantic.default_submodes
    (Ecamlx.Semantic.Submode.global_stickyfunc
    :: Ecaml.Customization.standard_value Ecamlx.Semantic.default_submodes);
  Ecaml.Minor_mode.enable Ecamlx.Minor_mode.semantic;

  (* Ispell *)

  (* Use hunspell instead of aspell because hunspell has a better French
     support. *)
  Ecamlx.Customization.set_variable Ecamlx.Ispell.program_name "hunspell";

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

  (* Flyspell *)
  Ecamlx.Customization.set_variable Ecamlx.Flyspell.use_meta_tab false;

  (* Filling *)
  Ecamlx.Customization.set_variable Ecamlx.Current_buffer.fill_column 72;
  Ecamlx.Customization.set_variable Ecamlx.Comment.multi_line true;
  Ecamlx.Customization.set_variable Ecamlx.Fill.nobreak_predicate
    (Ecamlx.Fill.french_nobreak_p
    :: Ecaml.Customization.standard_value Ecamlx.Fill.nobreak_predicate);

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
  Ecamlx.Customization.set_variable Ecamlx.Whitespace.style
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
       (Ecaml.Customization.standard_value Ecamlx.Whitespace.style));

  Ecamlx.Customization.set_variable Ecamlx.Whitespace.action
    [ Ecamlx.Whitespace.Action.Auto_cleanup ];

  (* Turn off whitespace-mode in Dired-like buffers.  *)
  Ecamlx.Customization.set_variable Ecamlx.Whitespace.global_modes
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
  Ecamlx.Customization.set_variable Ecamlx.Compilation.scroll_output
    `First_error;
  Ecamlx.Customization.set_variable Ecamlx.Compilation.context_lines
    (`Number_of_lines 0);
  Ecaml.Hook.add Ecamlx.Compilation.filter_hook ansi_color_compilation_filter;
  Ecaml.Feature.require Ecamlx.Compilation.feature;
  Ecamlx.Customization.set_variable Ecamlx.Compilation.error_regexp_alist
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
    @ Ecaml.Customization.standard_value Ecamlx.Compilation.error_regexp_alist);

  (* CC mode *)
  Ecaml.Hook.add Ecamlx.Cc_mode.initialization_hook c_initialization_hook_f;

  (* In java-mode and c++-mode, we use C style comments and not
     single-line comments. *)
  List.iter
    (fun (module Mode : Ecaml.Major_mode.S_with_lazy_keymap) ->
      Ecaml.Hook.add
        (Ecaml.Hook.major_mode_hook Mode.major_mode)
        c_trad_comment_on)
    [ (module Ecamlx.Major_mode.Java); (module Ecamlx.Major_mode.C_plus_plus) ];

  (* Scala *)
  Ecamlx.Customization.set_variable
    Ecamlx.Scala_mode.Indent.default_run_on_strategy `Operators;
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Scala.major_mode)
    scala_mode_hook_f;

  (* Markdown *)
  Ecamlx.Customization.set_variable Ecamlx.Markdown_mode.command "pandoc";
  Ecamlx.Customization.set_variable Ecamlx.Markdown_mode.asymmetric_header true;
  Ecamlx.Customization.set_variable
    Ecamlx.Markdown_mode.fontify_code_blocks_natively true;
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Markdown.major_mode)
    markdown_mode_hook_f;

  (* LaTeX *)
  Ecamlx.Customization.set_variable Ecamlx.Auctex.Tex.auto_save true;
  Ecamlx.Customization.set_variable Ecamlx.Auctex.Tex.parse_self true;
  Ecamlx.Customization.set_variable Ecamlx.Auctex.Latex.section_hook
    [ `Heading; `Title; `Toc; `Section; `Label ];
  Ecamlx.Customization.set_variable Ecamlx.Reftex.plug_into_auctex
    {
      Ecamlx.Reftex.supply_labels_in_new_sections_and_environments = true;
      supply_arguments_for_macros_like_label = true;
      supply_arguments_for_macros_like_ref = true;
      supply_arguments_for_macros_like_cite = true;
      supply_arguments_for_macros_like_index = true;
    };
  Ecamlx.Customization.set_variable Ecamlx.Reftex.enable_partial_scans true;
  Ecamlx.Customization.set_variable Ecamlx.Reftex.save_parse_info true;
  Ecamlx.Customization.set_variable Ecamlx.Reftex.use_multiple_selection_buffers
    true;
  Ecamlx.Customization.set_variable Ecamlx.Auctex.Tex.electric_math
    (Some ("$", "$"));
  Ecamlx.Customization.set_variable
    Ecamlx.Auctex.Tex.electric_sub_and_superscript true;
  Ecamlx.Customization.set_variable Ecamlx.Auctex.font_latex_fontify_script
    `Multi_level;
  Ecamlx.Customization.set_variable Ecamlx.Auctex.Tex.master `Query;
  Ecaml.Hook.add Ecamlx.Auctex.Latex.mode_hook enable_latex_minor_modes;

  (* Typst *)
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecamlx.Major_mode.Typst.major_mode)
    typst_mode_hook_f;

  (* Proof general *)
  Ecamlx.Customization.set_variable Ecamlx.Proof_general.splash_enable false;
  Ecamlx.Customization.set_variable
    Ecamlx.Proof_general.three_window_mode_policy `Hybrid;
  Ecamlx.Customization.set_variable
    Ecamlx.Proof_general.Coq.one_command_per_line false;

  (* Tuareg *)
  Ecamlx.Customization.set_variable Ecamlx.Tuareg.interactive_read_only_input
    true;
  Ecaml.Hook.add
    (Ecaml.Hook.major_mode_hook Ecaml.Major_mode.Tuareg.major_mode)
    tuareg_mode_hook_f;

  (* Enable smerge-mode when necessary.  *)
  Ecaml.Hook.add Ecamlx.Hook.find_file try_smerge;

  (* Completion *)
  Ecamlx.Customization.set_variable Ecamlx.Minibuffer.completion_auto_help
    `Always;
  Ecamlx.Customization.set_variable Ecamlx.Minibuffer.completion_auto_select
    `On_second_tab;

  (* To avoid interferences between Icomplete and the default completion
     system. *)
  Ecaml.Hook.add Ecamlx.Icomplete.minibuffer_setup_hook
    icomplete_minibuffer_setup_hook_f;

  (* Magit *)
  Ecaml.Feature.require Ecamlx.Git_commit.feature;
  Ecaml.Var.set_default_value Ecamlx.Magit.bind_magit_project_status false;
  Ecamlx.Customization.set_variable Ecamlx.Git_commit.summary_max_length
    (Ecaml.Customization.standard_value Ecamlx.Current_buffer.fill_column);
  Ecamlx.Customization.set_variable Ecamlx.Magit.commit_show_diff false;
  Ecamlx.Customization.set_variable Ecamlx.Magit.define_global_key_bindings
    false;
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

  Ecamlx.Customization.set_variable Ecamlx.Dired.completion_ignored_extensions
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
    @ Ecaml.Customization.standard_value
        Ecamlx.Dired.completion_ignored_extensions);

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
  Ecamlx.Customization.set_variable Ecamlx.Startup.inhibit_startup_screen true;
  Ecamlx.Customization.set_variable Ecamlx.Mode_line.compact `Long;
  Ecamlx.Customization.set_variable Ecamlx.Files.auto_mode_case_fold false;
  Ecamlx.Customization.set_variable Ecamlx.Startup.initial_buffer_choice
    (Some
       (`Function
         (Ecaml.Function.of_value_exn @@ Ecaml.Command.to_value
        @@ My.Command.ansi_term ())));
  Ecamlx.Customization.set_variable Ecamlx.Display.track_eol true;
  Ecamlx.Customization.set_variable Ecamlx.Minibuffer.completions_format
    `One_column;
  Ecamlx.Customization.set_variable
    Ecamlx.Minibuffer.enable_recursive_minibuffers true;
  Ecamlx.Customization.set_variable Ecamlx.Files.view_read_only true;
  Ecamlx.Customization.set_variable Ecamlx.Diff_mode.default_read_only true;
  Ecamlx.Customization.set_variable Ecamlx.Eldoc.echo_area_use_multiline_p
    `Never;
  Ecamlx.Customization.set_variable Ecamlx.Comint.prompt_read_only true;
  Ecamlx.Customization.set_variable Ecamlx.Term.buffer_maximum_size 0;
  Ecamlx.Customization.set_variable Ecamlx.Vc.follow_symlinks `Follow_link;
  Ecamlx.Customization.set_variable Ecamlx.Vc.command_messages true;
  Ecamlx.Customization.set_variable Ecamlx.Files.require_final_newline `Save;
  Ecamlx.Customization.set_variable Ecamlx.Current_buffer.scroll_up_aggressively
    (Some 0.);
  Ecamlx.Customization.set_variable
    Ecamlx.Current_buffer.scroll_down_aggressively (Some 0.);
  Ecamlx.Customization.set_variable Ecamlx.Indent.tabs_mode false;
  Ecamlx.Customization.set_variable Ecamlx.Imenu.auto_rescan true;
  Ecamlx.Customization.set_variable Ecamlx.Paren.context_when_offscreen
    `Echo_area;

  (* Custom global key bindings *)
  global_set_key "a" Ecamlx.Find_file.Command.get_other_file;
  global_set_key "c" (My.Command.compile ());
  global_set_key "b" Ecamlx.Windmove.Command.left;
  global_set_key "f" Ecamlx.Windmove.Command.right;
  global_set_key "h" Ecamlx.Man.Command.man;
  global_set_key "i" (My.Command.indent_buffer ());
  global_set_key "j" Ecamlx.Ffap.Command.find_file_at_point;
  global_set_key "k" Ecamlx.Command.kill_current_buffer;
  set_eglot_key "a" (Ecamlx.Eglot.Command.code_actions ());
  set_eglot_key "r" (Ecamlx.Eglot.Command.rename ());
  global_set_key "n" Ecamlx.Windmove.Command.down;
  set_ispell_key "c" Ecamlx.Ispell.Command.comments_and_strings;
  set_ispell_key "d" Ecamlx.Ispell.Command.change_dictionary;
  set_ispell_key "e" (My.Command.ispell_en ());
  set_ispell_key "f" (My.Command.ispell_fr ());
  set_ispell_key "o" Ecamlx.Ispell.Command.ispell;
  global_set_key "p" Ecamlx.Windmove.Command.up;
  global_set_key "s" (My.Command.git_grep ());
  global_set_key "t" (My.Command.transpose_windows ());
  global_set_key "u" (Ecamlx.Winner.Command.undo ());
  global_set_key "v" (My.Command.ansi_term ());
  global_set_key "w" Ecamlx.Whitespace.Command.cleanup;

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
      Ecamlx.Minor_mode.global_goto_address;
    ];

  Ecamlx.Frame.toggle_fullscreen ();

  (* Emacs server *)
  Ecamlx.Server.start ()

let () =
  let async_shutdown =
    let open Ecaml.Funcall.Wrap in
    "ecaml-async-shutdown" <: nullary @-> return nil
  in
  (* Hack to make the echoing of unfinished keystrokes work.  *)
  async_shutdown ();

  init ()
