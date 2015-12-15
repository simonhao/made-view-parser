/**
 * Made-View-Parser
 * @author: SimonHao
 * @date:   2015-12-15 13:24:06
 */

'use strict';

var Parser   = require('./lib/parser.js').Parser;
var Lexer    = require('./lib/parser.js').parser.lexer;
var inherits = require('util').inherits;

function ViewLexer(filename){
  this.filename = filename;
}

ViewLexer.prototype = Object.create(Lexer);

ViewLexer.prototype.parseError = function(msg, info){
  console.error('lexer error from file "', this.filename, '"');
  console.error(msg);

  throw new Error('Lexer Error');
};


function ViewParser(str, filename){
  this.str = str;
  this.filename = filename;

  this.lexer = new ViewLexer(filename);

  Parser.call(this);
}

inherits(ViewParser, Parser);

ViewParser.prototype.parse = function(){
  return Parser.prototype.parse.call(this, this.str);
};

ViewParser.prototype.parseError = function(msg, info){
  console.error('Parse error from file "', this.filename, '"');
  console.error(msg);

  throw new Error('Parse Error');
};

module.exports = ViewParser;