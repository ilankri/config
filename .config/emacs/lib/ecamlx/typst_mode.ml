module Lsp = struct
  let download_binary =
    let open Ecaml.Funcall.Wrap in
    "typst-ts-lsp-download-binary" <: nullary @-> return nil
end
