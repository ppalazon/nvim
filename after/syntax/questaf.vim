syntax match QuestafComment "//.*$"
syntax match QuestafOption "\v(\+incdir\+|\+define\+|\+libext\+)\S*"
syntax match QuestafOption "\v-(f|F|v|y|L|work)\s+\S+"
syntax match QuestafSource "\v\S+\.(sv|svh|v|vh|vhd|vhdl)"

highlight default link QuestafComment Comment
highlight default link QuestafOption Keyword
highlight default link QuestafSource String
