let library_name = "my"
let prefix_name name = Format.sprintf "%s-%s" library_name name

let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecamlx.defun ~name:(prefix_name name) ~__POS__ ?docstring ?define_keys
    ?obsoletes ?should_profile ?interactive ?disabled ?evil_config ~returns f

let hook_defun ~name ~__POS__ ?docstring ?should_profile ~hook_type ~returns f =
  Ecamlx.Hook.Function.create ~name:(prefix_name name) ~__POS__ ?docstring
    ?should_profile ~hook_type ~returns f

let csv_mode_hook_f =
  hook_defun ~name:"csv-mode-hook-f" ~__POS__
    ~hook_type:Ecaml.Hook.Hook_type.Normal_hook ~returns:Ecaml.Value.Type.unit
    (fun () ->
      Ecamlx.Current_buffer.set_buffer_local Ecamlx.Whitespace.style
        (List.filter
           (fun x -> x <> Ecamlx.Whitespace.Style.Lines)
           (Ecaml.Customization.value Ecamlx.Whitespace.style));
      Ecamlx.Current_buffer.set_buffer_local Ecamlx.Whitespace.action [])

let init =
  let init =
    let open Ecaml.Funcall.Wrap in
    "my-init" <: nullary @-> return nil
  in
  Ecaml.Feature.require @@ Ecaml.Symbol.intern "my0";
  init ();
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
