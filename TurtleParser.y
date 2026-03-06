{
module TurtleParser where
import TurtleLexer
}

%name parseTurtle
%tokentype  { Token }
%error      { parseError }

%token
    '.'     { TokenDot }
    ';'     { TokenSemiColon }
    ','     { TokenComma }
    ':'     { TokenColon }
    base    { TokenBase }
    prefix  { TokenPrefix }
    uri     { TokenURI $$ }
    str     { TokenString $$ }
    int     { TokenInteger $$ }
    var     { TokenVar $$ }

%%

TurtleDocs  :: { TurtleDoc }
TurtleDocs  :                           { CTurtleDocEmpty }
            | TurtleDocs TurtleDoc      { CTurtleDocP $1 $2 }

TurtleDoc   :: { TurtleDoc }
TurtleDoc   : Directive '.'             { CDirective $1 }
            | AbbrURI Predicates '.'    { CTripples $1 $2 }

Directive   :: { Directive }
Directive   : base uri                  { CBase $2 }
            | prefix var ':' uri        { CPrefix $2 $4 }

AbbrURI     :: { AbbrURI }
AbbrURI     : uri                       { CURI $1 }
            | var ':' var               { CAURI $1 $3 }

Predicate   :: { PredicateT }
Predicate   : AbbrURI ObjectList        { CPredicate $1 $2 }

Predicates  :: { PredicateT }
Predicates  : Predicate                 { $1 }
            | Predicates ';' Predicate  { CPredicateP $1 $3 }

ObjectItem  :: { Object }
ObjectItem  : AbbrURI                   { COURI $1 }
            | str                       { COStr $1 }
            | int                       { COInt $1 }

ObjectList  :: { Object }
ObjectList  : ObjectItem                { $1 }
            | ObjectList ',' ObjectItem { CObjects $1 $3 }

{
parseError :: [Token] -> a
parseError []    = error "Parse error: unexpected end of input"
parseError (t:_) = error $ "Parse error: unexpected token " ++ show t

data Directive
  = CBase String
  | CPrefix String String
  deriving (Eq, Show)

data AbbrURI
  = CURI String
  | CAURI String String
  deriving (Eq, Show)

data Object
  = CObjects Object Object
  | COURI AbbrURI
  | COStr String
  | COInt Int
  deriving (Eq, Show)

data PredicateT
  = CPredicate AbbrURI Object
  | CPredicateP PredicateT PredicateT
  deriving (Eq, Show)

data TurtleDoc
  = CDirective Directive
  | CTripples AbbrURI PredicateT
  | CTurtleDocP TurtleDoc TurtleDoc
  | CTurtleDocEmpty
  deriving (Eq, Show)
}
