let match_string ?(with_text_properties = false) ?string:s n =
  let match_string =
    let open Ecaml.Funcall.Wrap in
    (if with_text_properties then "match-string"
     else "match-string-no-properties")
    <: int @-> nil_or string @-> return (nil_or string)
  in
  match_string n s
