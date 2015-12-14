%start File

%%

File
  : Token-List EOF
    {
      $$ = $1;
      return $$;
    }
  | EOF
  ;

Token-List
  : Token
    %{
      $$ = [$1];
    %}
  | Token-List Token
    %{
      $$ = $1;
      $$.push($2);
    %}
  ;

Token
  : NAME -> $1
  | INDENT -> {type:'indent'}
  | OUTDENT -> {type:'outdent'}
  | CODE -> {type:'code'}
  | CLASS -> {type:'class', val:$1}
  | ORIGIN -> {type:'origin', val:$1}
  | PROPERTY-START -> $1
  | PROPERTY-CLOSE -> $1
  | '-' -> $1
  | "=" -> $1
  | "{" -> $1
  | "}" -> $1
  | "[" -> $1
  | "]" -> $1
  | "," -> $1
  | ":" -> $1
  | NUMBER -> {type:'number', val:$1}
  | STRING -> {type:'string', val:$1}
  ;