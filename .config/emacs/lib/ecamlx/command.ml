let from_string name = name |> Ecaml.Value.intern |> Ecaml.Command.of_value_exn
let kill_current_buffer = from_string "kill-current-buffer"
