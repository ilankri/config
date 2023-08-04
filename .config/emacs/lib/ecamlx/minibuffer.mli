val completions_format :
  [ `Horizontal | `Vertical | `One_column ] Ecaml.Customization.t

val enable_recursive_minibuffers : bool Ecaml.Customization.t

val completion_auto_help :
  [ `Never | `Only_when_cannot_complete | `Lazy | `Visible | `Always ]
  Ecaml.Customization.t

val completion_auto_select :
  [ `Never | `On_first_tab | `On_second_tab ] Ecaml.Customization.t
