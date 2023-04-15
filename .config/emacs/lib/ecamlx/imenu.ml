module Command = struct
  let imenu = Command.from_string "imenu"
end

let auto_rescan =
  let open Ecaml.Customization.Wrap in
  "imenu-auto-rescan" <: bool
