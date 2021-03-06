%start File


%%

File
  : Rule-List EOF
    %{
      $$ = {
        type: 'file',
        nodes: $1
      };

      return $$;
    %}
  | EOF
    %{
      $$ = {
        type: 'file',
        nodes: []
      };

      return $$;
    %}
  ;


Rule-List
  : Rule
    %{
      $$ = [$1];
    %}
  | Rule-List Rule
    %{
      $$ = $1;
      $$.push($2);
    %}
  ;

Rule
  : Qualified-Rule -> $1
  | Qualified-Rule INDENT Rule-List OUTDENT
    %{
      $$ = $1;
      $$.nodes = $3;
    %}
  ;

Qualified-Rule
  : Doctype ->$1
  | Tag -> $1
  | Custom-Tag -> $1
  | Code -> $1
  | Origin -> $1
  | Text -> $1
  | Comment -> $1
  | If -> $1
  | Else -> $1
  | ElseIf -> $1
  | While -> $1
  | Each -> $1
  | Case -> $1
  | When -> $1
  | Default -> $1
  | Block -> $1
  | Include -> $1
  | Extends -> $1
  ;

Extends
  : EXTEND TAG-TEXT Content-List
    %{
      $$ = {
        type: 'extends',
        id: $2,
        content: $3
      };
    %}
  | EXTEND Property-List TAG-TEXT Content-List
    %{
      $$ = {
        type: 'extends',
        option: $2,
        id: $3,
        content: $4
      };
    %}
  ;

Content-List
  : Content -> [$1]
  | Content-List Content
    %{
      $$ = $1;
      $$.push($2);
    %}
  ;

Content
  : Content-Type INDENT Rule-List OUTDENT
    %{
      $$ = {
        type: $1.type,
        block: $1.block,
        nodes: $3
      };
    %}
  ;

Content-Type
  : REPLACE
    %{
      $$ = {
        type: 'replace',
        block: $1
      };
    %}
  | BEFORE
    %{
      $$ = {
        type: 'before',
        block: $1
      };
    %}
  | AFTER
    %{
      $$ = {
        type: 'after',
        block: $1
      };
    %}
  ;

Include
  : INCLUDE TAG-TEXT
    %{
      $$ = {
        type: 'include',
        id: $2
      };
    %}
  | INCLUDE Property-List TAG-TEXT
    %{
      $$ = {
        type: 'include',
        option: $2,
        id: $3
      };
    %}
  ;

Block
  : BLOCK
    %{
      $$ = {
        type: 'block',
        name: $1
      };
    %}
  ;

Case
  : CASE
    %{
      $$ = {
        type: 'case',
        expr: $1
      };
    %}
  ;

When
  : WHEN
    %{
      $$ = {
        type: 'when',
        expr: $1
      };
    %}
  ;

Default
  : DEFAULT
    %{
      $$ = {
        type: 'default'
      };
    %}
  ;

Each
  : EACH EACH-VALUE EACH-DATA
    %{
      $$ = {
        type: 'each',
        value: $2,
        data: $3
      };
    %}
  | EACH EACH-VALUE EACH-INDEX EACH-DATA
    %{
      $$ = {
        type: 'each',
        value: $2,
        index: $3,
        data: $4
      };
    %}
  ;

If
  : IF
    %{
      $$ = {
        type: 'if',
        expr: $1
      };
    %}
  ;

Else
  : ELSE
    %{
      $$ = {
        type: 'else',
      };
    %}
  ;
ElseIf
  : ELSEIF
    %{
      $$ = {
        type: 'elseif',
        expr: $1
      };
    %}
  ;
While
  : WHILE
    %{
      $$ = {
        type: 'while',
        expr: $1
      };
    %}
  ;
Doctype
  : DOCTYPE TAG-TEXT
    %{
      $$ = {
        type: 'doctype',
        val: $2
      };
    %}
  ;

Comment
  : COMMENT
    %{
      $$ = {
        type: 'comment',
        val: $1
      };
    %}
  ;

Text
  : TEXT
    %{
      $$ = {
        type: 'text',
        val: $1
      };
    %}
  ;

Tag
  : Tag-Name
    %{
      $$ = {
        type: 'tag',
        name: $1
      };
    %}
  | Tag-Name TAG-TEXT
    %{
      $$ = {
        type: 'tag',
        name: $1,
        text: $2
      };
    %}
  | Tag-Name Class-List
    %{
      $$ = {
        type: 'tag',
        name: $1,
        class_list: $2
      };
    %}
  | Tag-Name Class-List TAG-TEXT
    %{
      $$ = {
        type: 'tag',
        name: $1,
        class_list: $2,
        text: $3
      };
    %}
  | Tag-Name Property-List
    %{
      $$ = {
        type: 'tag',
        name: $1,
        property_list: $2
      };
    %}
  | Tag-Name Property-List TAG-TEXT
    %{
      $$ = {
        type: 'tag',
        name: $1,
        property_list: $2,
        text: $3
      };
    %}
  | Tag-Name Class-List Property-List
    %{
      $$ = {
        type: 'tag',
        name: $1,
        class_list: $2,
        property_list: $3
      };
    %}
  | Tag-Name Class-List Property-List TAG-TEXT
    %{
      $$ = {
        type: 'tag',
        name: $1,
        class_list: $2,
        property_list: $3,
        text: $4
      };
    %}
  ;
Tag-Name
  : IDENT -> $1
  ;

Class-List
  : Class -> [$1]
  | Class-List Class
    %{
      $$ = $1;
      $$.push($2);
    %}
  ;
Class
  : CLASS
    %{
      $$ = {
        type: 'class',
        val: $1
      };
    %}
  ;

Property-List
  : "(" Property-Set ")" -> $2
  ;
Property-Set
  : Property -> [$1]
  | Property-Set "," Property
    %{
      $$ = $1;
      $$.push($3);
    %}
  ;
Property
  : Property-Name
    %{
      $$ = {
        type: 'property',
        name: $1,
        boolean: true
      };
    %}
  | Property-Name "=" JSON-Value
    %{
      $$ = {
        type: 'property',
        name: $1,
        val: $3
      };
    %}
  ;
Property-Name
  : IDENT -> $1
  | Property-Name "-" IDENT -> $1+$2+$3
  ;

JSON-Value
  : JSON-Reference-Value -> $1
  | JSON-Number -> $1
  | JSON-String -> $1
  | JSON-Literal -> $1
  | JSON-Reference-List -> $1
  ;

JSON-Reference-Value
  : JSON-Ident -> $1
  | JSON-Object -> $1
  | JSON-Array -> $1
  ;

JSON-Reference
  : '.' IDENT
    %{
      $$ = {
        type: 'json_literal',
        val: $1+$2
      };
    %}
  | "[" STRING "]"
    %{
      $$ = {
        type: 'json_literal',
        val: $1+'"'+$2+'"'+$3
      };
    %}
  | "[" NUMBER "]"
    %{
      $$ = {
        type: 'json_literal',
        val: $1+$2+$3
      };
    %}
  ;

JSON-Reference-List
  : JSON-Reference-Value JSON-Reference
    %{
      $$ = {
        type: 'json_reference_list',
        ident: $1,
        list: [$2]
      };
    %}
  | JSON-Reference-List JSON-Reference
    %{
      $$ = $1
      $$.list.push($2);
    %}
  ;

JSON-Number
  : NUMBER
    %{
      $$ = {
        type: 'json_number',
        val: $1
      };
    %}
  ;
JSON-String
  : STRING
    %{
      $$ = {
        type: 'json_string',
        val: $1
      };
    %}
  ;
JSON-Literal
  : JSON-Literal-Element
    %{
      $$ = {
        type: 'json_literal',
        val: $1
      };
    %}
  ;
JSON-Literal-Element
  : TRUE -> $1
  | FALSE -> $1
  | NULL -> $1
  ;


JSON-Ident
  : IDENT
    %{
      $$ = {
        type: 'json_ident',
        val: $1
      };
    %}
  ;
JSON-Object
  : "{" JSON-Member-List "}"
    %{
      $$ = {
        type: 'json_object',
        member: $2
      };
    %}
  ;
JSON-Member-List
  : JSON-Member -> [$1]
  | JSON-Member-List "," JSON-Member
    %{
      $$ = $1;
      $$.push($3);
    %}
  ;
JSON-Member
  : IDENT ":" JSON-Value
    %{
      $$ = {
        type: 'json_member',
        name: $1,
        val: $3
      };
    %}
  ;
JSON-Array
  : "[" JSON-Element-List "]"
    %{
      $$ = {
        type: 'json_array',
        element: $2
      };
    %}
  ;
JSON-Element-List
  : JSON-Value -> [$1]
  | JSON-Element-List "," JSON-Value
    %{
      $$ = $1;
      $$.push($3);
    %}
  ;

Custom-Tag
  : Custom-Tag-Name
    %{
      $$ = {
        type: 'custom_tag',
        name: $1
      };
    %}
  | Custom-Tag-Name TAG-TEXT
    %{
      $$ = {
        type: 'custom_tag',
        name: $1,
        text: $2
      };
    %}
  | Custom-Tag-Name Property-List
    %{
      $$ = {
        type: 'custom_tag',
        name: $1,
        option: $2
      };
    %}
  | Custom-Tag-Name Property-List TAG-TEXT
    %{
      $$ = {
        type: 'custom_tag',
        name: $1,
        option: $2,
        text: $3
      };
    %}
  ;
Custom-Tag-Name
  : Tag-Name ":" Tag-Name -> $1+':'+$3
  | Custom-Tag-Name-List -> $1
  | Custom-Tag-Name-List ":" Tag-Name -> $1+':'+$3
  ;

Custom-Tag-Name-List
  : Tag-Name "-" Tag-Name -> $1+'/'+$3
  | Custom-Tag-Name-List "-" Tag-Name -> $1+'/'+$3
  ;

Code
  : CODE
    %{
      $$ = {
        type: 'code',
        val: $1
      };
    %}
  ;

Origin
  : ORIGIN
    %{
      $$ = {
        type: 'origin',
        val: $1
      };
    %}
  ;