{
module TurtleLexer where  
}

%wrapper "basic"

$white = [\ \t\n\r]
$digit = [0-9]
$alpha = [a-zA-Z]

tokens :-  
  $white+ ;
  \.  { \s -> TokenDot } 
  \;  { \s -> TokenSemicolon }
  \,  { \s -> TokenComma }
  \@base  { \s -> TokenBase }
  \@prefix  { \s -> TokenPrefix }
  \< [^\>]+ \>  { \s -> TokenURI s }
  ($alpha | $digit)+ \: ($alpha | $digit)+  { \s -> TokenNickname s }
  \" [^\"]* \"  { \s -> TokenString s }
  [\+\-]? $digit+  { \s -> TokenInteger (read s) }

{
data Token
  = TokenURI String
  | TokenNickname String
  | TokenString String
  | TokenInteger Int
  | TokenDot
  | TokenSemicolon
  | TokenComma
  | TokenBase
  | TokenPrefix
  deriving (Eq, Show)
}
