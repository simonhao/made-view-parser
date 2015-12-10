
%start File

%%

File
  : EOF
    {
      $$ = [];

      return $$;
    }
  | Token-List EOF
    {
      $$ = $1;

      return $$;
    }
  ;

Token-List
  : Token
    {
      $$ = [$1];
    }
  | Token-List Token
    {
      $$ = $1;
      $$.push($2);

    }
  ;

Token
  : INDENT -> {type:'ident'}
  | OUTDENT -> {type:'outdent'}
  | NEWLINE -> {type:'newline'}
  | PROPERTY-START -> {type:'property-start'}
  | PROPERTY-CLOSE -> {type:'property-close'}
  | IDENT -> {type:'property-ident'}
  | STRING -> {type:'property-string'}
  | NUMBER -> {type:'property-number'}
  | TRUE -> {type:'property-true'}
  | FALSE -> {type:'property-false'}
  | NULL -> {type:'property-null'}
  | CODE -> {type:'code', val:$1}
  | TAG -> {type:'tag', val:$1}
  | HTML -> {type:'html', val:$1}
  | ORIGIN-START -> {type:'origin-start'}
  | ORIGIN -> {type: 'origin', val:$1}
  | EXTEND -> {type: 'extend'}
  | REPLACE -> {type:'replace', val:$1}
  | INCLUDE -> {type: 'include'}
  | BLOCK -> {type: 'block', val:$1}
  | COMMENT -> {type:'comment', val:$1}
  | CLASS -> {type:'class', val:$1}
  | COMPONENT-ID -> {type:'component_id', val:$1}
  | DOCTYPE -> {type:'doctype', val:$1}
  | "=" -> $1
  | "["
  | "]"
  | "{"
  | "}"
  | ","
  | ":"
  | TOKEN -> $1
  ;












