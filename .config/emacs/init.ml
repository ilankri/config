let init () =
  Ecaml.Var.set_default_value Ecamlx.load_prefer_newer true;
  My.init ()

let () = init ()
