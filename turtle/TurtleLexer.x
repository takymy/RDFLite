{
module TurtleLexer where  
}

%wrapper "basic"

$digit = [0-9]
$alpha = [a-zA-Z]

tokens :-  
  $white+ ;
  \.                { \s -> TokenDot } 
  \;                { \s -> TokenSemicolon }
  \,                { \s -> TokenComma }
  \:                { \s -> TokenColon }
  \@base            { \s -> TokenBase }
  \@prefix          { \s -> TokenPrefix }
  \< [^\>]+ \>      { \s -> TokenURI s }
  \" [^\"]* \"      { \s -> TokenString s }
  [\+\-]? $digit+   { \s -> TokenInteger (read s) }
  ($alpha|$digit)+  { \s -> TokenVar s }

{
data Token
  = TokenDot
  | TokenSemicolon
  | TokenComma
  | TokenColon
  | TokenBase
  | TokenPrefix
  | TokenURI String
  | TokenString String
  | TokenInteger Int
  | TokenVar String
  deriving (Eq, Show)
}
