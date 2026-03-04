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

%left '.'
%left ';'
%left ','
%left ':'
%left base
%left prefix
%left uri
%left str
%left int
%left var
%%
TurtleDoc   : Directive '.'             { CDirective $1 }
            | AbbrURI Predicates '.'    { CTripples $1 $2 }
            | TurtleDoc TurtleDoc       { CTurtleDocP $1 $2 }

Directive   : base uri                  { CBase $2 }
            | prefix var ':' uri        { CPrefix $2 $4 }

AbbrURI     : uri                       { CURI $1 }
            | var ':' var               { CAUIR $1 $3 }

Predicates  : AbbrURI Object            { CPredicate $1 $2 }
            | Predicates ';' Predicates { CPredicateP $1 $3 }

Object      : Object ',' Object         { CObjectP $1 $3 }
            | AbbrURI                   { COURI $1 }
            | str                       { COStr $1}
            | int                       { COInt $1}

{
parseError = error "parse error"

data Directive 
  = CBase String 
  | CPrefix String String
  deriving (Eq, Show)

data AbbrURI 
  = CURI String 
  | CAUIR String String
  deriving (Eq, Show)

data Object 
  = CObjects Object Object 
  | COURI AbbrURI 
  | COStr String 
  | COInt Int
  deriving (Eq, Show)

data PredicateT 
  = CPredicate AbbrURI Object 
  | CPredicateP Predicate Predicate
  deriving (Eq, Show)

data TurtleDoc
  = CDirective Directive 
  | CTripples AbbrURI Predicates
  deriving (Eq, Show)
}