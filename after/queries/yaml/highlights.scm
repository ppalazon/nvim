; extends

; Spell check values (not keys) so the buffer spelling language also applies
; to prose in YAML, not only to comments.
(block_mapping_pair
  value: (flow_node
    [
      (plain_scalar (string_scalar))
      (double_quote_scalar)
      (single_quote_scalar)
    ] @spell))

(flow_pair
  value: (flow_node
    [
      (plain_scalar (string_scalar))
      (double_quote_scalar)
      (single_quote_scalar)
    ] @spell))

(block_mapping_pair
  value: (block_node (block_scalar) @spell))

(block_sequence_item
  (flow_node
    [
      (plain_scalar (string_scalar))
      (double_quote_scalar)
      (single_quote_scalar)
    ] @spell))

(block_sequence_item
  (block_node (block_scalar) @spell))
