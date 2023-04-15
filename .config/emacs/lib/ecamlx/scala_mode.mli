module Indent : sig
  val default_run_on_strategy :
    [ `Eager | `Operators | `Reluctant ] Ecaml.Customization.t
end
