let _init_packages =
  Ecamlx.defun ~name:"my-init-packages" ~__POS__
    ~returns:(Ecaml.Returns.Returns Ecaml.Value.Type.unit)
    (let open Ecaml.Defun.Let_syntax in
    return () >>| My.init_package_archives >>| fun () ->
    Ecamlx.Package.refresh_contents ())
