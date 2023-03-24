let init () =
  let init =
    let open Ecaml.Funcall.Wrap in
    "my-init" <: nullary @-> return nil
  in
  Ecaml.Var.set_default_value Ecaml.Load.path
    ((Ecaml.Var.default_value_exn Ecamlx.user_emacs_directory ^ "lib/my")
    :: Ecaml.Var.default_value_exn Ecaml.Load.path);
  Ecaml.Var.set_default_value Ecamlx.load_prefer_newer true;
  Ecaml.Feature.require @@ Ecaml.Symbol.intern "my";
  init ()

let () = init ()
