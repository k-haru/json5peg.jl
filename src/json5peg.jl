module json5peg
using PEG

export json5_parse
json5_parse(json5text) = parse_whole(JSON5Text, json5text)

@rule JSON5Text =
    nodata & JSON5Value & nodata |> x -> x[2]

@rule nodata =
    (WhiteSpace, LineTerminatorSequence, Comment)[*]

@rule WhiteSpace =
    "\t",
    "\v",
    "\f",
    " ",
    "\u00A0",
    "\uFEFF",
    "\u3000"

@rule LineTerminatorSequence =
    "\n",
    "\r\n",
    "\r",
    "\u2028",
    "\u2029"

@rule Comment =
    SingleLineComment,
    MultiLineComment

@rule SingleLineComment =
    "//" & r"."[*] & LineTerminatorSequence |> x -> nothing

@rule MultiLineComment =
   r"\/\*.*?\*\/" |> x -> nothing

@rule JSON5Value =
    JSON5Null,
    JSON5Boolean,
    JSON5Number,
    JSON5String,
    JSON5Array,
    JSON5Object

@rule JSON5Null =
    "null" |> x -> nothing

@rule JSON5Boolean =
    "true" |> x -> true,
    "false" |> x -> false

@rule JSON5Number =
    r"-?(0|[1-9]\d*)(\.\d+)?([Ee][+-]?\d+)?"p |> Meta.parse

@rule JSON5String =
    JSON5DoubleString,
    JSON5SingleString

@rule JSON5Array =
"[" & nodata & (JSON5Value & nodata)[*] & "]" |> x -> x[3]

@rule JSON5Object =
"{" & nodata "}" |> x -> Dict(),
"{" & nodata & JSON5MemberList & nodata & r","? & nodata & "}" |> x -> x[3]

@rule JSON5MemberList =
    JSON5Member & (nodata & r"," & nodata & JSON5Member)[*] |> x -> Dict(x[1], x[3])

@rule JSON5DoubleString =
    "\"" & JSON5DoubleStringCharacter[*] & "\"" |> x -> join(x[2])

@rule JSON5SingleString =
    "'" & JSON5SingleStringCharacter[*] & "'" |> x -> join(x[2])

@rule JSON5DoubleStringCharacter =
    JSON5DoubleStringCharacterUnescaped,
    JSON5DoubleStringCharacterEscaped

@rule JSON5SingleStringCharacter =
    JSON5SingleStringCharacterUnescaped,
    JSON5SingleStringCharacterEscaped

@rule JSON5DoubleStringCharacterUnescaped =
    r"[^\"\\]" |> x -> x[1]

@rule JSON5SingleStringCharacterUnescaped =
    r"[^\'\\]" |> x -> x[1]

@rule JSON5DoubleStringCharacterEscaped =
    "\\" & JSON5EscapeSequence |> x -> x[2]

@rule JSON5SingleStringCharacterEscaped =
    "\\" & JSON5EscapeSequence |> x -> x[2]

@rule JSON5EscapeSequence =
    JSON5EscapeCharacter,
    JSON5SingleEscapeCharacter,
    JSON5NonEscapeCharacter

@rule JSON5EscapeCharacter =
    r"[\"\\\/bfnrt]" |> x -> x[1]

@rule JSON5SingleEscapeCharacter =
    r"[\'\\\/bfnrt]" |> x -> x[1]

@rule JSON5NonEscapeCharacter =
    r"[^\"]" |> x -> x[1]

@rule JSON5Member =
    JSON5MemberName & nodata & ":" & nodata & JSON5Value |> x -> (x[1], x[5])

@rule JSON5MemberName =
    JSON5Identifier,
    JSON5String

@rule JSON5Identifier =
    JSON5IdentifierStart & JSON5IdentifierPart[*] |> x -> join(x)

@rule JSON5IdentifierStart =
    UnicodeLetter,
    "$",
    "_",
    "\\" & JSON5UnicodeEscapeSequence |> x -> x[2]

@rule JSON5IdentifierPart =
    JSON5IdentifierStart,
    UnicodeCombiningMark,
    UnicodeDigit,
    UnicodeConnectorPunctuation,
    "\\u200C",
    "\\u200D"

@rule JSON5UnicodeEscapeSequence =
    "\\u" & [UnicodeHexDigit[*]] |> x -> join(x[2])



end
