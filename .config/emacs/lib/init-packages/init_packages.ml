let init_packages () =
  My.init_package_archives ();
  Ecamlx.Package.refresh_contents ()

let () = init_packages ()
