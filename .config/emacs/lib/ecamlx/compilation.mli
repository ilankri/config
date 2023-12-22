val feature : Ecaml.Feature.t
val scroll_output : [ `Yes | `No | `First_error ] Ecaml.Customization.t

val context_lines :
  [ `Scroll_when_no_fringe | `Never_scroll | `Number_of_lines of int ]
  Ecaml.Customization.t

val filter_hook : Ecaml.Hook.normal Ecaml.Hook.t

module Command : sig
  val recompile : Ecaml.Command.t
end

module Error_matcher : sig
  type subexpression = int

  type type_ =
    | Explicit of [ `Error | `Warning | `Info ]
    | Conditional of {
        warning_if_match : subexpression;
        info_if_match : subexpression;
      }

  type range = {
    start : [ `Subexpression of subexpression | `Function of Ecaml.Function.t ];
    end_ :
      [ `Subexpression of subexpression | `Function of Ecaml.Function.t ] option;
  }

  type t = {
    regexp : Ecaml.Regexp.t;
    file :
      [ `Subexpression of subexpression * string list
      | `Function of Ecaml.Function.t ];
    line : range option;
    column : range option;
    type_ : type_;
    hyperlink : subexpression option;
    highlights :
      (subexpression * Ecaml.Face.t * Ecaml.Face.Attribute_and_value.t list)
      list;
  }
end

val error_regexp_alist :
  [ `Error_matcher of Error_matcher.t | `Symbol of Ecaml.Symbol.t ] list
  Ecaml.Customization.t
