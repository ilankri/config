module Latex = struct
  module Minor_mode = struct
    let math = Minor_mode.make "LaTeX-math-mode"
  end

  let mode_hook =
    let open Ecaml.Hook.Wrap in
    "LaTeX-mode-hook" <: Ecaml.Hook.Hook_type.Normal_hook

  let section_hook =
    let type_ =
      let module Type = struct
        type t = [ `Heading | `Title | `Toc | `Section | `Label ]

        let all = [ `Heading; `Title; `Toc; `Section; `Label ]

        let sexp_of_t value =
          let hook =
            match value with
            | `Heading -> "heading"
            | `Title -> "title"
            | `Toc -> "toc"
            | `Section -> "section"
            | `Label -> "label"
          in
          Sexplib0.Sexp.Atom (Format.sprintf "LaTeX-section-%s" hook)
      end in
      Value.Type.enum "LaTeX-section-hook" (module Type)
    in
    let open Ecaml.Customization.Wrap in
    "LaTeX-section-hook" <: list type_
end

module Tex = struct
  module Minor_mode = struct
    let pdf = Minor_mode.make "TeX-PDF-mode"
    let source_correlate = Minor_mode.make "TeX-source-correlate-mode"
  end

  let auto_save =
    let open Ecaml.Customization.Wrap in
    "TeX-auto-save" <: bool

  let parse_self =
    let open Ecaml.Customization.Wrap in
    "TeX-parse-self" <: bool

  let electric_math =
    let type_ =
      let to_ value =
        if Ecaml.Value.is_nil value then None
        else
          Some
            ( value |> Ecaml.Value.car_exn |> Ecaml.Value.to_utf8_bytes_exn,
              value |> Ecaml.Value.cdr_exn |> Ecaml.Value.to_utf8_bytes_exn )
      in
      let from = function
        | None -> Ecaml.Value.nil
        | Some (before, after) ->
            Ecaml.Value.cons
              (Ecaml.Value.of_utf8_bytes before)
              (Ecaml.Value.of_utf8_bytes after)
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "TeX-electric-math") to_sexp
        to_ from
    in
    let open Ecaml.Customization.Wrap in
    "TeX-electric-math" <: type_

  let electric_sub_and_superscript =
    let open Ecaml.Customization.Wrap in
    "TeX-electric-sub-and-superscript" <: bool

  let master =
    let type_ =
      let shared = Ecaml.Value.intern "shared" in
      let dwim = Ecaml.Value.intern "dwim" in
      let to_ value =
        if Ecaml.Value.is_nil value then `Query
        else if Ecaml.Value.eq value Ecaml.Value.t then `This_file
        else if Ecaml.Value.eq value shared then `Shared
        else if Ecaml.Value.eq value dwim then `Dwim
        else `File (Ecaml.Value.to_utf8_bytes_exn value)
      in
      let from = function
        | `Query -> Ecaml.Value.nil
        | `This_file -> Ecaml.Value.t
        | `Shared -> shared
        | `Dwim -> dwim
        | `File file -> Ecaml.Value.of_utf8_bytes file
      in
      let to_sexp value = value |> from |> Ecaml.Value.sexp_of_t in
      Ecaml.Value.Type.create (Sexplib0.Sexp.Atom "TeX-master") to_sexp to_ from
    in
    let open Ecaml.Customization.Wrap in
    "TeX-master" <: type_
end

let font_latex_fontify_script =
  let type_ =
    let module Type = struct
      type t = [ `Yes | `No | `Multi_level | `Invisible ]

      let all = [ `Yes; `No; `Multi_level; `Invisible ]

      let sexp_of_t value =
        let atom =
          match value with
          | `Yes -> "t"
          | `No -> "nil"
          | `Multi_level -> "multi-level"
          | `Invisible -> "invisible"
        in
        Sexplib0.Sexp.Atom atom
    end in
    Value.Type.enum "font-latex-fontify-script" (module Type)
  in

  let open Ecaml.Customization.Wrap in
  "font-latex-fontify-script" <: type_
