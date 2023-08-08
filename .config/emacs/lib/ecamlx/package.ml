let feature = Ecaml.Symbol.intern "package"

let archives =
  let open Ecaml.Customization.Wrap in
  "package-archives" <: list (tuple string string)

let selected_packages =
  let open Ecaml.Customization.Wrap in
  "package-selected-packages" <: list Ecaml.Symbol.type_

let initialize ?no_activate () =
  let initialize =
    let open Ecaml.Funcall.Wrap in
    "package-initialize" <: nil_or bool @-> return nil
  in
  initialize no_activate

let install_selected_packages ?no_confirm () =
  let install_selected_packages =
    let open Ecaml.Funcall.Wrap in
    "package-install-selected-packages" <: nil_or bool @-> return nil
  in
  install_selected_packages no_confirm
