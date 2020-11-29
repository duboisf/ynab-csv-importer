def record_import_id_prefix($id_prefix):
    .ids[$id_prefix] |= (. // 0) + 1;

def to_import_id($import_ids; $key):
    $key + ($import_ids[$key] | tostring);

# Convert a transaction to the import_id format used by YNAB. This format is
# "YNAB:yyyy-mm-dd:amount:occurence". Do note that it doesn't include the
# occurence here, which shall be computed later to produce the full import_id.
def to_id($transaction):
      $transaction
    | ["YNAB", .date, (.amount | tostring)] | join(":") | . + ":";

# . is the cumulative object containing the seen ids and processed
# transactions. The reduce step updates the seen import_ids (contained in .ids)
# and then adds the import_id to the current transaction (contained in
# $transaction) and appends the transaction to the transactions by computing the
# full import_id.
def reduce_step($transaction):
      to_id($transaction) as $id_prefix
    | record_import_id_prefix($id_prefix)
    | .transactions += [$transaction + {"import_id": to_import_id(.ids; $id_prefix)}]
    ;

reduce .transactions[] as $transaction ({"ids": {}, "transactions": []}; reduce_step($transaction))
  | del(.ids)
