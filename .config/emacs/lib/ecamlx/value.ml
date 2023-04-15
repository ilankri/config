module Type = struct
  let enum (type a) name (module Type : Enum.S with type t = a) =
    Ecaml.Value.Type.enum (Sexplib0.Sexp.Atom name)
      (module Type)
      (fun value ->
        value |> Type.sexp_of_t |> Sexplib0.Sexp.to_string |> Ecaml.Value.intern)
end
