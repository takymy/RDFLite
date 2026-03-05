{
module TurtleParser where
import TurtleLexer
}

%name parseTurtle
%tokentype  { Token }
%error      { parseError }

%token
    '.'     { TokenDot }
    ';'     { TokenSemicolon }
    ','     { TokenComma }
    ':'     { TokenColon }
    base    { TokenBase }
    prefix  { TokenPrefix }
    uri     { TokenURI $$ }
    str     { TokenString $$ }
    int     { TokenInteger $$ }
    var     { TokenVar $$ }

%%

TurtleDoc   : Statement '.'             { [$1] }
            | TurtleDoc Statement '.'   { $2 : $1 }

Statement   : base uri                  { Base $2 }
            | prefix var ':' uri        { Prefix $2 $4 }
            | Resource PredObjList      { Tripples $1 $2 }

PredObjList : PredObj                   { [$1] }
            | PredObjList ';' PredObj   { $3 : $1 }

PredObj     : Resource ObjList          { PredObjC $1 $2 }

ObjList     : Value                     { [$1] }
            | ObjList ',' Value         { $3 : $1 }

Value  : Resource                       { VRes $1 }
            | str                       { VStr $1}
            | int                       { VInt $1}

Resource    : uri                       { URI $1 }
            | var ':' var               { AURI $1 $3 }

{
parseError = error "parse error"

data Statement
  = Base String 
  | Prefix String String
  | Tripples Resource [PredObj]
  deriving (Eq, Show)

data PredObj 
  = PredObjC Resource [Value]
  deriving (Eq, Show)

data Value
  = VRes Resource 
  | VStr String 
  | VInt Int
  deriving (Eq, Show)

data Resource 
  = URI String 
  | AURI String String
  deriving (Eq, Show)
}