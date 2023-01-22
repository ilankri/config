let library_name = "my"

let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecamlx.defun
    ~name:(Format.sprintf "%s-%s" library_name name)
    ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile ?interactive
    ?disabled ?evil_config ~returns f

let init =
  let init =
    let open Ecaml.Funcall.Wrap in
    "my-init" <: nullary @-> return nil
  in
  Ecaml.Feature.require @@ Ecaml.Symbol.intern "my0";
  init ();
  Ecamlx.Custom.load_theme "modus-operandi";

  (* Emacs server *)
  Ecamlx.Server.start ();

  Ecaml.Defun.return ()

let () =
  defun ~name:"init" ~__POS__ ~returns:Ecaml.Value.Type.unit init;
  Ecaml.provide @@ Ecaml.Symbol.intern library_name
