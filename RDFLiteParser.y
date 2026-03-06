{
module RDFLiteParser where
import RDFLiteLexer
}

%name parseRDFLite
%tokentype { Token }
%error { parseError }

%token
  'OUTPUT' { TokenOutput }
  'FROM' { TokenFrom }
  'WHERE' { TokenWhere }
  'FILTER' { TokenFilter }
  'GROUP' { TokenGroup }
  'BY' { TokenBy }
  'AGGREGATE' { TokenAggregate }
  'AS' { TokenAs }
  'OR' { TokenOr }
  'MAX' { TokenMax }
  '*' { TokenStar }
  '{' { TokenLBrace }
  '}' { TokenRBrace }
  '(' { TokenLParen }
  ')' { TokenRParen }
  '.' { TokenDot }
  ',' { TokenComma }
  '>=' { TokenGte }
  '=' { TokenEq }
  var { TokenVar $$ }
  uri { TokenURI $$ }
  string { TokenString $$ }
  int { TokenInteger $$ }

%nonassoc '>=' '='
%left 'OR'

%%

Query :: { Query }
Query : 'OUTPUT' OutputSpec 'FROM' GraphList 'WHERE' '{' PatternBlock '}' OptFilter OptGroup { Query $2 $4 $7 $9 $10 }

OutputSpec :: { OutputSpec }
OutputSpec : Term Term Term { OutTriple $1 $2 $3 }
  | '*' { OutStar }

GraphList :: { [String] }
GraphList : uri               { [$1] }
          | GraphList ',' uri { $1 ++ [$3] }

PatternBlock :: { [TriplePattern] }
PatternBlock :                            { [] }
             | PatternBlock TriplePattern { $1 ++ [$2] }

TriplePattern :: { TriplePattern }
TriplePattern : Term Term Term '.' { TriplePattern $1 $2 $3 }

OptFilter :: { Maybe Expr }
OptFilter : { Nothing }
  | 'FILTER' Expr { Just $2 }

OptGroup :: { Maybe GroupAgg }
OptGroup : { Nothing }
  | 'GROUP' 'BY' var 'AGGREGATE' 'MAX' '(' var ')' 'AS' var { Just (GroupAgg $3 $7 $10) }

Expr :: { Expr }
Expr : Term '=' Term { CmpEq $1 $3 }
  | Term '>=' Term { CmpGte $1 $3 }
  | Expr 'OR' Expr { ExprOr $1 $3 }
  | '(' Expr ')' { $2 }

Term :: { Term }
Term : var { Var $1 }
  | uri { URI $1 }
  | string { Str $1 }
  | int { IntVal $1 }

{
parseError :: [Token] -> a
parseError [] = error "Parse error: unexpected end of input"
parseError (t:_) = error $ "Parse error: unexpected token " ++ show t

data Query = Query OutputSpec [String] [TriplePattern] (Maybe Expr) (Maybe GroupAgg) deriving (Show, Eq)

data OutputSpec = OutStar | OutTriple Term Term Term deriving (Show, Eq)

data TriplePattern = TriplePattern Term Term Term deriving (Show, Eq)

data Term = Var String | URI String | Str String | IntVal Int deriving (Show, Eq)

data Expr = CmpEq Term Term | CmpGte Term Term | ExprOr Expr Expr deriving (Show, Eq)

data GroupAgg = GroupAgg String String String deriving (Show, Eq)
}
