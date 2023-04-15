let feature = Ecaml.Symbol.intern "ispell"

module Command = struct
  let message = Command.from_string "ispell-message"
  let comments_and_strings = Command.from_string "ispell-comments-and-strings"
  let change_dictionary = Command.from_string "ispell-change-dictionary"
  let ispell = Command.from_string "ispell"
end

let program_name =
  let open Ecaml.Customization.Wrap in
  "ispell-program-name" <: string

let change_dictionary ?globally dictionary =
  let change_dictionary =
    let open Ecaml.Funcall.Wrap in
    "ispell-change-dictionary" <: string @-> nil_or bool @-> return nil
  in
  change_dictionary dictionary globally

let dictionary =
  let open Ecaml.Customization.Wrap in
  "ispell-dictionary" <: nil_or string

let local_dictionary =
  let local_dictionary =
    let open Ecaml.Buffer_local.Wrap in
    Ecaml.Feature.require feature;
    "ispell-local-dictionary" <: nil_or string
  in
  local_dictionary |> Ecaml.Buffer_local.var |> Customization.from_variable

let ispell =
  let open Ecaml.Funcall.Wrap in
  "ispell" <: nullary @-> return nil
