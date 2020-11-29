def prependZero:
    if (. | tonumber) < 10 then "0" + . else . end;

def convertDate:
    split("/") | map(prependZero) | [.[2], .[0], .[1]] | join("-");

def toMilliunits:
    . + "0" | gsub("\\."; "") | tonumber;

def removeDoubleQuotes:
    gsub("\""; "");

def csv2json:
    split("\n") |
        map(
            if . == "" then
                empty
            else
                  removeDoubleQuotes
                | split(",")
                | {
                    "date": (.[0] | convertDate),
                    "amount": (.[2] | toMilliunits),
                    "payee_name": .[1],
                    "memo": .[3]
                  }
            end
        );

def to_full_transaction:
    {
        "account_id": $account_id,
        date,
        amount,
        payee_name,
        "cleared": "cleared",
        approved: false
    };

csv2json | {"transactions": [.[] | to_full_transaction]}
