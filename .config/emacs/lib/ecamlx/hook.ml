let find_file =
  let open Ecaml.Hook.Wrap in
  "find-file-hook" <: Ecaml.Hook.Hook_type.Normal_hook

let post_self_insert =
  let open Ecaml.Hook.Wrap in
  "post-self-insert-hook" <: Ecaml.Hook.Hook_type.Normal_hook

module Function = struct
  let create ~name ~__POS__ ?docstring ?should_profile ~hook_type ~returns f =
    Ecaml.Hook.Function.create (Ecaml.Symbol.intern name)
      (Position.to_lexing_position ~__POS__)
      ~docstring:(Option.value ~default:"None" docstring)
      ?should_profile ~hook_type (Ecaml.Returns.Returns returns) f
end
