let feature = Ecaml.Symbol.intern "winner"

module Command = struct
  let undo () =
    Ecaml.Feature.require feature;
    Command.from_string "winner-undo"
end
