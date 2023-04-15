let make ?variable_name function_name =
  let variable_name = Option.map Ecaml.Symbol.intern variable_name in
  let function_name = Ecaml.Symbol.intern function_name in
  Ecaml.Minor_mode.create ?variable_name function_name

let auto_fill = make "auto-fill-mode"
let semantic = make "semantic-mode"
let smerge = make "smerge-mode"
let global_whitespace = make "global-whitespace-mode"
let tool_bar = make "tool-bar-mode"
let menu_bar = make "menu-bar-mode"
let scroll_bar = make "scroll-bar-mode"
let column_number = make "column-number-mode"
let global_subword = make "global-subword-mode"
let delete_selection = make "delete-selection-mode"
let electric_indent = make "electric-indent-mode"
let electric_pair = make "electric-pair-mode"
let show_paren = make "show-paren-mode"
let savehist = make "savehist-mode"
let winner = make "winner-mode"
let fido_vertical = make "fido-vertical-mode"
let minibuffer_depth_indicate = make "minibuffer-depth-indicate-mode"
let global_auto_revert = make "global-auto-revert-mode"
let diff = make "diff-minor-mode"
let flyspell = make "flyspell-mode"
let reftex = make "reftex-mode"
let auto_insert = make "auto-insert-mode"
let global_goto_address = make "global-goto-address-mode"
