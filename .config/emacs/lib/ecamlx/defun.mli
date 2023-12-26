val defun :
  name:string ->
  __POS__:Position.t ->
  ?docstring:string ->
  ?define_keys:(Ecaml.Keymap.t * string) list ->
  ?obsoletes:Ecaml.Defun.Obsoletes.t ->
  ?should_profile:bool ->
  ?interactive:Ecaml.Defun.Interactive.t ->
  ?disabled:Ecaml.Symbol.Disabled.t ->
  ?evil_config:Ecaml.Evil.Config.t ->
  returns:(_, 'a) Ecaml.Returns.t ->
  'a Ecaml.Defun.t ->
  unit

val lambda :
  __POS__:Position.t ->
  ?docstring:string ->
  ?interactive:Ecaml.Defun.Interactive.t ->
  returns:(_, 'a) Ecaml.Returns.t ->
  'a Ecaml.Defun.t ->
  Ecaml.Function.t
