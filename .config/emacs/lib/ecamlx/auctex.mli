module Latex : sig
  module Minor_mode : sig
    val math : Ecaml.Minor_mode.t
  end

  val mode_hook : Ecaml.Hook.normal Ecaml.Hook.t

  val section_hook :
    [ `Heading | `Title | `Toc | `Section | `Label ] list Ecaml.Customization.t
end

module Tex : sig
  module Minor_mode : sig
    val pdf : Ecaml.Minor_mode.t
    val source_correlate : Ecaml.Minor_mode.t
  end

  val auto_save : bool Ecaml.Customization.t
  val parse_self : bool Ecaml.Customization.t
  val electric_math : (string * string) option Ecaml.Customization.t
  val electric_sub_and_superscript : bool Ecaml.Customization.t

  val master :
    [ `Query | `This_file | `Shared | `Dwim | `File of string ]
    Ecaml.Customization.t
end

val font_latex_fontify_script :
  [ `Yes | `No | `Multi_level | `Invisible ] Ecaml.Customization.t
