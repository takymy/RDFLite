# RDFLite Query Language Design

## Overview

RDFLite is a domain-specific language (DSL) for querying RDF graphs in Turtle format.  
Input consists of one or more `.ttl` files; output is produced in canonical N-Triples subset format.

---

## 1. Program Structure

An RDFLite program consists of a single query statement with the following skeleton:

```
OUTPUT <output-spec>
FROM <graph-list>
WHERE { <triple-patterns> }
[FILTER <expr>]
[GROUP BY <var> AGGREGATE <agg> AS <var>]
```

---

## 2. Full BNF Grammar

```bnf
<program>        ::=  <query>

<query>          ::=  'OUTPUT' <output-spec>
                      'FROM' <graph-list>
                      'WHERE' <pattern-block>
                      [ 'FILTER' <expr> ]
                      [ 'GROUP' 'BY' <var> 'AGGREGATE' <agg-expr> 'AS' <var> ]

<output-spec>    ::=  <term> <term> <term>
                   |  '*'

<graph-list>     ::=  <graph-ref> ( ',' <graph-ref> )*
<graph-ref>      ::=  STRING_LITERAL

<pattern-block>  ::=  '{' <triple-pattern>+ '}'
<triple-pattern> ::=  <term> <term> <term> '.'

<term>           ::=  URI
                   |  STRING_LITERAL
                   |  INTEGER_LITERAL
                   |  <var>

<var>            ::=  '?' IDENTIFIER

<expr>           ::=  <compare>
                   |  <expr> 'OR' <expr>
                   |  '(' <expr> ')'

<compare>        ::=  <term> <comp-op> <term>
<comp-op>        ::=  '='  |  '>='

<agg-expr>       ::=  'MAX' '(' <var> ')'
```

---

## 3. Clause Descriptions

### 3.1 OUTPUT — Output Definition

Defines how RDF triples are generated from variable bindings.

- **Triple template**: specifies subject, predicate, object (may use variables and constants)
- **`OUTPUT *`**: outputs all matched triples (used for graph union scenarios)

```rdflite
OUTPUT ?x <http://example.org/ont/hasAge> ?age
OUTPUT *
```

### 3.2 FROM — Input Graphs

Specifies one or more Turtle files as input. Multiple files are separated by commas; their triples are merged into a unified graph.

```rdflite
FROM "foo.ttl"
FROM "foo.ttl", "bar.ttl"
```

### 3.3 WHERE — Triple Pattern Matching

Contains a set of triple patterns enclosed in curly braces. Each pattern consists of three terms followed by a dot. Multiple patterns are automatically joined through shared variables.

```rdflite
WHERE {
    ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?y .
    ?y <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?z .
}
```

### 3.4 FILTER — Filter Conditions (Optional)

Filters variable bindings. Supports `=` (URI/value equality) and `>=` (integer comparison), combined with `OR`.

```rdflite
FILTER ?age >= 21
FILTER ?p = <http://example.org/ont/studiesAt> OR ?p = <http://example.org/ont/worksFor>
```

### 3.5 GROUP BY ... AGGREGATE (Optional)

Groups by a variable and applies `MAX` to another variable. The result is bound to a new variable for use in OUTPUT.

```rdflite
GROUP BY ?x
AGGREGATE MAX(?price) AS ?maxPrice
```

---

## 4. Variables and RDF Terms

| Type | Syntax | Example |
|---|---|---|
| Variable | `?` + identifier | `?x`, `?name`, `?age` |
| URI | `<` + IRI + `>` | `<http://example.org/foo>` |
| String | double-quoted | `"hello"` |
| Integer | digit sequence | `42`, `21` |

---

## 5. Query Examples

### Task 1: Graph Union

Merge all triples from `foo.ttl` and `bar.ttl`, removing duplicates.

```rdflite
OUTPUT *
FROM "foo.ttl", "bar.ttl"
WHERE {
    ?s ?p ?o .
}
```

### Task 2: Pattern Matching — Predicate + Integer Comparison

Output triples where the predicate is `hasAge` and the object value is >= 21.

```rdflite
OUTPUT ?s <http://example.org/ont/hasAge> ?age
FROM "baz.ttl"
WHERE {
    ?s <http://example.org/ont/hasAge> ?age .
}
FILTER ?age >= 21
```

### Task 3: Further Pattern Matching — OR + URI Matching

Output triples where the predicate is `studiesAt` or `worksFor` and the object is `uos`.

```rdflite
OUTPUT ?x ?p <http://example.org/uos>
FROM "qux.ttl"
WHERE {
    ?x ?p <http://example.org/uos> .
}
FILTER ?p = <http://example.org/ont/studiesAt> OR ?p = <http://example.org/ont/worksFor>
```

### Task 4: Aggregates — GROUP BY + MAX

Group by subject and take the maximum `price` value.

```rdflite
OUTPUT ?x <http://example.org/ont/price> ?maxPrice
FROM "quux.ttl"
WHERE {
    ?x <http://example.org/ont/price> ?price .
}
GROUP BY ?x
AGGREGATE MAX(?price) AS ?maxPrice
```

### Task 5: Cross-Graph JOIN

Infer new type triples via `rdf:type` + `rdfs:subClassOf`.

```rdflite
OUTPUT ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?z
FROM "xyzzy.ttl", "plugh.ttl"
WHERE {
    ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?y .
    ?y <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?z .
}
```

---

## 6. Output Semantics

1. Substitute variables in the `OUTPUT` template with each set of matched bindings
2. All URIs are expanded to their full form `<http://...>`
3. Integers are output as plain numbers, e.g.: `<http://example.org/alice> <http://example.org/ont/hasAge> 21 .`
4. Strings are output in double quotes, e.g.: `<http://example.org/alice> <http://example.org/name> "Nick" .`
5. Results are **deduplicated** and **sorted lexicographically**
6. One triple per line in the format: `<s> <p> <o> .` (canonical N-Triples subset)

---

## 7. Lexical Token Table

| Token | Pattern | Purpose |
|---|---|---|
| `TokenOutput` | `OUTPUT` | Keyword |
| `TokenFrom` | `FROM` | Keyword |
| `TokenWhere` | `WHERE` | Keyword |
| `TokenFilter` | `FILTER` | Keyword |
| `TokenGroup` | `GROUP` | Keyword |
| `TokenBy` | `BY` | Keyword |
| `TokenAggregate` | `AGGREGATE` | Keyword |
| `TokenAs` | `AS` | Keyword |
| `TokenOr` | `OR` | Logical operator |
| `TokenMax` | `MAX` | Aggregate function |
| `TokenStar` | `*` | Wildcard output |
| `TokenVar` | `?[a-zA-Z][a-zA-Z0-9]*` | Variable |
| `TokenURI` | `<...>` | URI |
| `TokenString` | `"..."` | String literal |
| `TokenInteger` | `[+-]?[0-9]+` | Integer literal |
| `TokenLBrace` | `{` | Left brace |
| `TokenRBrace` | `}` | Right brace |
| `TokenLParen` | `(` | Left parenthesis |
| `TokenRParen` | `)` | Right parenthesis |
| `TokenDot` | `.` | Triple terminator |
| `TokenComma` | `,` | List separator |
| `TokenEq` | `=` | Equality comparison |
| `TokenGte` | `>=` | Greater-than-or-equal |
