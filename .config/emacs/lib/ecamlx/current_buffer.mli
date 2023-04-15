val fill_column : int Ecaml.Customization.t
val inhibit_read_only : bool Ecaml.Var.t
val set_buffer_local : 'a Ecaml.Var.t -> 'a -> unit
val set_customization_buffer_local : 'a Ecaml.Customization.t -> 'a -> unit
val scroll_up_aggressively : float option Ecaml.Customization.t
val scroll_down_aggressively : float option Ecaml.Customization.t
