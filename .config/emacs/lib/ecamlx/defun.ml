let defun ~name ~__POS__ ?docstring ?define_keys ?obsoletes ?should_profile
    ?interactive ?disabled ?evil_config ~returns f =
  Ecaml.defun (Ecaml.Symbol.intern name)
    (Position.to_lexing_position ~__POS__)
    ~docstring:(Option.value ~default:"None" docstring)
    ?define_keys ?obsoletes ?should_profile ?interactive ?disabled ?evil_config
    returns f

let lambda ~__POS__ ?docstring ?interactive ~returns f =
  Ecaml.lambda
    (Position.to_lexing_position ~__POS__)
    ?docstring ?interactive returns f
