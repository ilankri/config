let feature = Ecaml.Symbol.intern "grep"

let read_regexp =
  let open Ecaml.Funcall.Wrap in
  "grep-read-regexp" <: nullary @-> return Ecaml.Regexp.t
