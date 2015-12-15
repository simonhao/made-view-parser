/**
 * Test
 * @author: SimonHao
 * @date:   2015-12-08 10:32:11
 */

'use strict';
var fs = require('fs');
var parser = require('../lib/parser.js').parser;

var filename = __dirname + '/layout.jade';
var str = fs.readFileSync(filename, 'utf-8');

var result = parser.parse(str);

console.log(JSON.stringify(result));