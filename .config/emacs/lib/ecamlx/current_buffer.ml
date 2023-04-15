let fill_column =
  Ecaml.Current_buffer.fill_column |> Ecaml.Buffer_local.var
  |> Customization.from_variable

let inhibit_read_only =
  let open Ecaml.Var.Wrap in
  "inhibit-read-only" <: bool

let set_buffer_local variable value =
  Ecaml.Current_buffer.set_buffer_local
    (Ecaml.Buffer_local.wrap_existing ~make_buffer_local_always:true
       (Ecaml.Var.symbol variable)
       (Ecaml.Var.type_ variable))
    value

let set_customization_buffer_local variable value =
  let variable = Ecaml.Customization.var variable in
  set_buffer_local variable value

let scroll_up_aggressively =
  let open Ecaml.Customization.Wrap in
  "scroll-up-aggressively" <: nil_or Ecaml.Customization.Wrap.float

let scroll_down_aggressively =
  let open Ecaml.Customization.Wrap in
  "scroll-down-aggressively" <: nil_or Ecaml.Customization.Wrap.float
