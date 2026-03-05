{
module RDFLiteLexer where
}

%wrapper "basic"

$digit = [0-9]
$alpha = [a-zA-Z]

tokens :-
  $white+ ;
  "OUTPUT"          { \s -> TokenOutput }
  "FROM"            { \s -> TokenFrom }
  "WHERE"           { \s -> TokenWhere }
  "FILTER"          { \s -> TokenFilter }
  "GROUP"           { \s -> TokenGroup }
  "BY"              { \s -> TokenBy }
  "AGGREGATE"       { \s -> TokenAggregate }
  "AS"              { \s -> TokenAs }
  "OR"              { \s -> TokenOr }
  "MAX"             { \s -> TokenMax }
  \* { \s -> TokenStar }
  \{                { \s -> TokenLBrace }
  \}                { \s -> TokenRBrace }
  \(                { \s -> TokenLParen }
  \)                { \s -> TokenRParen }
  \.                { \s -> TokenDot }
  \,                { \s -> TokenComma }
  \>\=              { \s -> TokenGte }
  \=                { \s -> TokenEq }
  \? $alpha ($alpha | $digit)* { \s -> TokenVar s }
  \< [^\>]+ \>      { \s -> TokenURI s }
  \" [^\"]* \"      { \s -> TokenString s }
  [\+\-]? $digit+   { \s -> TokenInteger (read s) }

{
data Token
  = TokenOutput
  | TokenFrom
  | TokenWhere
  | TokenFilter
  | TokenGroup
  | TokenBy
  | TokenAggregate
  | TokenAs
  | TokenOr
  | TokenMax
  | TokenStar
  | TokenLBrace
  | TokenRBrace
  | TokenLParen
  | TokenRParen
  | TokenDot
  | TokenComma
  | TokenGte
  | TokenEq
  | TokenVar String
  | TokenURI String
  | TokenString String
  | TokenInteger Int
  deriving (Eq, Show)
}
