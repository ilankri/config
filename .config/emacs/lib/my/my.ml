let prefix_name name = Format.sprintf "my-%s" name

let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecamlx.Defun.defun ~name:(prefix_name name) ~__POS__ ?docstring ?define_keys
    ?obsoletes ?should_profile ?interactive ?disabled ?evil_config ~returns f

let hook_defun
    ?(name = Ecaml.Symbol.name @@ Ecaml.Symbol.gensym ~prefix:"hook-f" ())
    ~__POS__ ?docstring ?should_profile ~hook_type ~returns f =
  Ecamlx.Hook.Function.create ~name:(prefix_name name) ~__POS__ ?docstring
    ?should_profile ~hook_type ~returns f

module Command = struct
  let from_string name =
    prefix_name name |> Ecaml.Value.intern |> Ecaml.Command.of_value_exn

  let ispell dict =
    let old_dict =
      match Ecaml.Customization.value Ecamlx.Ispell.local_dictionary with
      | Some old_dict -> old_dict
      | None ->
          Option.value ~default:"default"
            (Ecaml.Customization.value Ecamlx.Ispell.dictionary)
    in
    Ecamlx.Ispell.change_dictionary dict;
    Ecamlx.Ispell.ispell ();
    Ecamlx.Ispell.change_dictionary old_dict

  let ispell_en () =
    let name = "ispell-en" in
    defun ~name ~__POS__ ~returns:(Ecaml.Returns.Returns Ecaml.Value.Type.unit)
      ~interactive:Ecaml.Defun.Interactive.No_arg
      (let open Ecaml.Defun.Let_syntax in
       return () >>| fun () -> ispell "en_US");
    from_string name

  let ispell_fr () =
    let name = "ispell-fr" in
    defun ~name ~__POS__ ~returns:(Ecaml.Returns.Returns Ecaml.Value.Type.unit)
      ~interactive:Ecaml.Defun.Interactive.No_arg
      (let open Ecaml.Defun.Let_syntax in
       return () >>| fun () -> ispell "fr_FR");
    from_string name

  let indent_buffer () =
    let name = "indent-buffer" in
    defun ~name ~__POS__ ~returns:(Ecaml.Returns.Returns Ecaml.Value.Type.unit)
      ~interactive:Ecaml.Defun.Interactive.No_arg
      (let open Ecaml.Defun.Let_syntax in
       return () >>| fun () ->
       Ecaml.Current_buffer.indent_region ~start:(Ecaml.Point.min ())
         ~end_:(Ecaml.Point.max ()) ());
    from_string name

  let git_grep () =
    let name = "git-grep" in
    defun ~name ~__POS__ ~returns:(Ecaml.Returns.Returns Ecaml.Value.Type.unit)
      ~interactive:Ecaml.Defun.Interactive.No_arg
      (let open Ecaml.Defun.Let_syntax in
       return () >>| fun () ->
       Ecaml.Feature.require Ecamlx.Grep.feature;
       Ecaml.Feature.require Ecamlx.Vc.Git.feature;
       Ecamlx.Vc.Git.grep ?dir:(Ecamlx.Vc.root_dir ()) ~files:""
         (Ecamlx.Grep.read_regexp ()));
    from_string name

  let ansi_term () =
    let name = "ansi-term" in
    defun ~name ~__POS__
      ~returns:(Ecaml.Returns.Returns_deferred Ecaml.Buffer.type_)
      ~interactive:Ecaml.Defun.Interactive.Raw_prefix
      (let open Ecaml.Defun.Let_syntax in
       Ecaml.Defun.optional_with_default "arg" false Ecaml.Defun.bool
       >>| fun arg ->
       let default_buffer_name = "terminal" in
       let new_buffer_name =
         if arg then
           Ecaml.Completing.read ~history:Ecaml.Minibuffer.history
             ~collection:[] ~default:default_buffer_name ~prompt:"Name: " ()
         else Async_kernel.return default_buffer_name
       in
       Async_kernel.Deferred.map new_buffer_name ~f:(fun new_buffer_name ->
           Ecamlx.Term.ansi_term ~new_buffer_name
             (Option.value
                ~default:
                  (Ecaml.Customization.value Ecamlx.Process.shell_file_name)
                (Ecaml.System.getenv ~var:"ESHELL"))));
    from_string name
end

let init_package_archives () =
  Ecaml.Feature.require Ecamlx.Package.feature;
  Ecamlx.Customization.set_variable Ecamlx.Package.archives
    (Ecaml.Customization.standard_value Ecamlx.Package.archives
    @ [ ("melpa-stable", "https://stable.melpa.org/packages/") ])
