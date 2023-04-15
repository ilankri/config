module Type : sig
  val enum : string -> (module Enum.S with type t = 'a) -> 'a Ecaml.Value.Type.t
end
