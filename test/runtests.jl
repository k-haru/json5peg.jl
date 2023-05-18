using Test, json5peg
json5_str="""
{
  unquoted: 'and you can quote me on that',
  singleQuotes: 'I can use "double quotes" here',
  lineBreaks: "Look, Mom!  No \\n's!",
  hexadecimal: 912559,
  leadingDecimalPoint: 0.8675309,
  andTrailing: 8675309,
  positiveSign: 1,
  trailingComma: 'in objects',
  andIn: [
    'arrays',
  ],
  backwardsCompatible: 'with JSON',
}
"""


@test json5_parse(json5_str)
