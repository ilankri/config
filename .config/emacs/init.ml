let init () =
  Ecaml.Var.set_default_value Ecamlx.load_prefer_newer true;
  My.init ()

let () =
  let async_shutdown =
    let open Ecaml.Funcall.Wrap in
    "ecaml-async-shutdown" <: nullary @-> return nil
  in
  (* Hack to make the echoing of unfinished keystrokes work.  *)
  async_shutdown ();

  init ()
