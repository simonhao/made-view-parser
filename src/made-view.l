%{
  global.indent_stack = global.indent_stack || [0];
%}

%x state-indent
%x state-outdent
%x state-property
%x state-tag
%x state-origin
%x state-component


digit       [0-9]
nmstart     [_$a-zA-Z]
nmchar      {nmstart}|{digit}|[-]
ident       {nmstart}{nmchar}*

space       " "
tab         \t
whitespace  {space}|{tab}
newline     \r\n|\n|\r|\f

string      {string1}|{string2}
string1     \"([^\n\r\f\\"]|\\{newline})*\"
string2     \'([^\n\r\f\\']|\\{newline})*\'

true        "true"
false       "false"
null        "null"
number      [+-]?([0-9]+|[0-9]*\.[0-9]+)("e"[+-]?[0-9]+)?

extend      "extend"
include     "include"
replace     "replace"
block       "block"
doctype     "doctype"

property-start       "("
property-close       ")"

code-start           "-"{whitespace}+
html-start           "|"{whitespace}+
comment-start        "//"{whitespace}*
dot-start            "."

%%


<INITIAL>{newline}
  %{
    this.begin('state-indent');
  %}
<state-indent><<EOF>>
  %{
    return 'EOF';
  %}
<state-indent>{whitespace}*{newline}
  %{
    /* ignore blank line */
  %}
<state-indent>{whitespace}*
  %{
    this.popState();

    if(yyleng > indent_stack[0]){
      indent_stack.unshift(yyleng);
      return 'INDENT';
    }else if(yyleng < indent_stack[0]){
      while(yyleng < indent_stack[0]){
        indent_stack.shift();
        this.begin('state-outdent');
      }
    }
  %}
<state-outdent>
  %{
    this.popState();
    return 'OUTDENT';
  %}


<INITIAL>{code-start}[^\n\r\f]*
  %{
    yytext = yytext.substring(1).trim();
    return 'CODE';
  %}
<INITIAL>{html-start}[^\n\r\f]*
  %{
    yytext = yytext.substring(1).trim();
    return 'HTML';
  %}
<INITIAL>{comment-start}[^\n\r\f]*
  %{
    yytext = yytext.substring(2).trim();
    return 'COMMENT';
  %}
<INITIAL>{doctype}{whitespace}+[^\n\r\f]+
  %{
    yytext = yytext.substring(7).trim();
    return 'DOCTYPE';
  %}
<INITIAL>{extend}
  %{
    this.begin('state-component');
    return 'EXTEND';
  %}
<INITIAL>{replace}{whitespace}+{ident}
  %{
    yytext = yytext.substring(7).trim();
    return 'REPLACE';
  %}
<INITIAL>{include}
  %{
    this.begin('state-component');
    return 'INCLUDE';
  %}
<INITIAL>{block}{whitespace}+{ident}
  %{
    yytext = yytext.substring(5).trim();
    return 'BLOCK';
  %}


<INITIAL>{ident}
  %{
    this.begin('state-tag');
    return 'TAG';
  %}
<state-tag><<EOF>>
  %{
    return 'EOF';
  %}
<state-tag>{dot-start}{ident}
  %{
    yytext = yytext.substring(1);
    return 'CLASS';
  %}
<state-tag>{dot-start}{whitespace}*{newline}
  %{
    this.popState();
    this.begin('state-origin');
  %}
<state-tag>{property-start}
  %{
    this.begin('state-property');
    return 'PROPERTY-START';
  %}
<state-tag>{whitespace}+[^\n\r\f]*
  %{
    this.popState();

    yytext = yytext.trim();
    if(yytext){
      return 'HTML';
    }
  %}
<state-tag>
  %{
    this.popState();
  %}


<state-origin><<EOF>>
  %{
    return 'EOF';
  %}
<state-origin>{newline}{whitespace}*{newline}{whitespace}*
  %{
    /* ignore blank line */
  %}
<state-origin>{newline}{whitespace}*
  %{
    if((yyleng-1) <= indent_stack[0]){
      this.popState();

      while((yyleng-1) < indent_stack[0]){
        indent_stack.shift();
        this.begin('state-outdent');
      }
    }
  %}
<state-origin>{whitespace}+
  %{
    /* ignore start blank line */
  %}
<state-origin>{whitespace}*{newline}{whitespace}*
  %{
    /* ignore start blank line */
  %}
<state-origin>[^\n\r\f]*
  %{
    return 'ORIGIN';
  %}


<state-component>{whitespace}*{property-start}
  %{
    this.begin('state-property');
    return 'PROPERTY-START';
  %}
<state-component>{whitespace}+[^\r\n\f]+
  %{
    this.popState();
    return 'COMPONENT-ID';
  %}

<state-property>{newline}|{whitespace}
  %{
    /* ignore whitespace */
  %}
<state-property>{string}
  %{
    return 'STRING';
  %}
<state-property>{true}
  %{
    return 'TRUE';
  %}
<state-property>{false}
  %{
    return 'FALSE';
  %}
<state-property>{null}
  %{
    return 'NULL';
  %}
<state-property>{number}
  %{
    return 'NUMBER';
  %}
<state-property>"["|"]"|"{"|"}"|":"|","|"="
  %{
    return yytext;
  %}
<state-property>{ident}
  %{
    return 'IDENT';
  %}
<state-property>{property-close}
  %{
    this.popState();

    return 'PROPERTY-CLOSE';
  %}



<INITIAL><<EOF>> {return 'EOF';}


%%