%{
  global.indent_stack = global.indent_stack || [0];
%}

%x STATE-INDENT
%x STATE-ORIGIN
%x STATE-PROPERTY
%x STATE-EACH

digit       [0-9]
nmstart     [_$a-zA-Z]
nmchar      {nmstart}|{digit}
ident       {nmstart}{nmchar}*
name        {nmstart}({nmchar}|[-])*

open-paren  "("
close-paren ")"
dot         "."
hyphen      "-"
space       " "
tab         \t
column      "|"
whitespace  {space}|{tab}
newline     \r\n|\n|\r|\f

string      {string1}|{string2}
string1     \"([^\n\r\f\\"]|\\{newline})*\"
string2     \'([^\n\r\f\\']|\\{newline})*\'

true        "true"
false       "false"
null        "null"
number      [+-]?([0-9]+|[0-9]*\.[0-9]+)("e"[+-]?[0-9]+)?

extend      "extends"
include     "include"
replace     "replace"
before      "before"
after       "after"
block       "block"
doctype     "doctype"
comment     "//"

if          "if"
else        "else"
elseif      "else if"
while       "while"
each        "each"
case        "case"
when        "when"
default     "default"
in          "in"
%%

<INITIAL>{extend}
  %{
    return 'EXTEND';
  %}
<INITIAL>{include}
  %{
    return 'INCLUDE';
  %}
<INITIAL>{replace}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(7).trim();
    return 'REPLACE';
  %}
<INITIAL>{before}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(6).trim();
    return 'BEFORE';
  %}
<INITIAL>{after}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(5).trim();
    return 'AFTER';
  %}
<INITIAL>{block}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(5).trim();
    return 'BLOCK'
  %}
<INITIAL>{case}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(4).trim();
    return 'CASE';
  %}
<INITIAL>{when}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(4).trim();
    return 'WHEN';
  %}
<INITIAL>{default}{whitespace}*{newline}
  %{
    this.unput('\n');
    return 'DEFAULT';
  %}
<INITIAL>{each}{whitespace}+
  %{
    this.begin('STATE-EACH');
    return 'EACH';
  %}

<INITIAL>{if}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(2).trim();
    return 'IF';
  %}
<INITIAL>{elseif}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(7).trim();
    return 'ELSEIF';
  %}
<INITIAL>{else}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(4).trim();
    return 'ELSE';
  %}
<INITIAL>{while}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(5).trim();
    return 'WHILE';
  %}
<INITIAL>{doctype}
  %{
    return 'DOCTYPE';
  %}
<INITIAL>{ident}
  %{
    return 'IDENT';
  %}
<INITIAL>{hyphen}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(1).trim();
    return 'CODE';
  %}
<INITIAL>{hyphen}
  %{
    return '-';
  %}
<INITIAL>{dot}{name}
  %{
    yytext = yytext.substring(1);
    return 'CLASS';
  %}
<INITIAL>{dot}{whitespace}*{newline}
  %{
    this.begin('STATE-ORIGIN');
    this.unput('\n');
  %}
<INITIAL>{open-paren}
  %{
    this.begin('STATE-PROPERTY');
    return '(';
  %}
<INITIAL>{column}[^\r\n\f]*
  %{
    yytext = yytext.substring(1).trim();
    return 'TEXT';
  %}
<INITIAL>{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.trim();
    return 'TAG-TEXT';
  %}
<INITIAL>{comment}{whitespace}+[^\r\n\f]*
  %{
    yytext = yytext.substring(2).trim();
    return 'COMMENT';
  %}


<STATE-EACH>","{whitespace}*{ident}{whitespace}+
  %{
    yytext = yytext.substring(1).trim();
    return 'EACH-INDEX';
  %}
<STATE-EACH>{in}{whitespace}+[^\r\n\f]*
  %{
    this.popState();

    yytext = yytext.substring(2).trim();
    return 'EACH-DATA';
  %}
<STATE-EACH>{ident}{whitespace}*
  %{
    yytext = yytext.trim();
    return 'EACH-VALUE';
  %}



<STATE-PROPERTY>{whitespace}|{newline}
  %{
    /* ignore whitespace and newline */
  %}
<STATE-PROPERTY>{ident}
  %{
    return 'IDENT';
  %}
<STATE-PROPERTY>{string}
  %{
    yytext = yytext.substring(1, yytext.length-1);
    return 'STRING';
  %}
<STATE-PROPERTY>{number}
  %{
    return "NUMBER";
  %}
<STATE-PROPERTY>{hyphen}
  %{
    return '-'
  %}
<STATE-PROPERTY>"."
  %{
    return ".";
  %}
<STATE-PROPERTY>"{"
  %{
    return "{";
  %}
<STATE-PROPERTY>"}"
  %{
    return "}";
  %}
<STATE-PROPERTY>"["
  %{
    return "[";
  %}
<STATE-PROPERTY>"]"
  %{
    return "]";
  %}
<STATE-PROPERTY>","
  %{
    return ",";
  %}
<STATE-PROPERTY>":"
  %{
    return ":";
  %}
<STATE-PROPERTY>"="
  %{
    return "=";
  %}
<STATE-PROPERTY>{true}
  %{
    return 'TRUE';
  %}
<STATE-PROPERTY>{false}
  %{
    return 'FALSE';
  %}
<STATE-PROPERTY>{null}
  %{
    return 'NULL';
  %}
<STATE-PROPERTY>{close-paren}
  %{
    this.popState();
    return ')';
  %}




<STATE-ORIGIN>{newline}{whitespace}*{newline}
  %{
    /* ignore blank line */
    this.unput('\n');
  %}
<STATE-ORIGIN>{newline}{whitespace}*
  %{
    if((yyleng-1) <= indent_stack[0]){
      this.popState();

      var unput_char = [];

      while((yyleng-1) < indent_stack[0]){
        indent_stack.shift();
        unput_char.push('<<OUTDENT>>');
      }

      if(unput_char.length){
        this.unput(unput_char.join(''));
      }
    }
  %}
<STATE-ORIGIN><<EOF>>
  %{
    this.popState();

    if(indent_stack[0] > 0){
      var unput_char = [];

      while(indent_stack[0] > 0){
        indent_stack.shift();
        unput_char.push('<<OUTDENT>>');
      }

      this.unput(unput_char.join(''));
    }else{
      return 'EOF';
    }
  %}
<STATE-ORIGIN>[^\r\n\f]*
  %{
    return 'ORIGIN';
  %}




<INITIAL>{newline}
  %{
    this.begin('STATE-INDENT');
  %}
<STATE-INDENT>{whitespace}*{newline}
  %{
    /* ignore blank line */
  %}
<STATE-INDENT>{whitespace}*
  %{
    this.popState();

    if(yyleng > indent_stack[0]){
      indent_stack.unshift(yyleng);
      return 'INDENT';
    }else if(yyleng < indent_stack[0]){
      var unput_char = [];

      while(yyleng < indent_stack[0]){
        indent_stack.shift();
        unput_char.push('<<OUTDENT>>');
      }

      this.unput(unput_char.join(''));
    }
  %}
<INITIAL>"<<OUTDENT>>"
  %{
    return 'OUTDENT';
  %}
<INITIAL><<EOF>>
  %{
    if(indent_stack[0] > 0){
      var unput_char = [];

      while(indent_stack[0] > 0){
        indent_stack.shift();
        unput_char.push('<<OUTDENT>>');
      }

      this.unput(unput_char.join(''));
    }else{
      return 'EOF';
    }
  %}