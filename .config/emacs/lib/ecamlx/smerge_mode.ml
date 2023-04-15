let feature = Ecaml.Symbol.intern "smerge-mode"

let begin_re =
  let open Ecaml.Var.Wrap in
  "smerge-begin-re" <: Ecaml.Regexp.t
