let from_string name = name |> Ecaml.Value.intern |> Ecaml.Command.of_value_exn
let blink_matching_open = from_string "blink-matching-open"
let switch_to_completions = from_string "switch-to-completions"
let kill_current_buffer = from_string "kill-current-buffer"
