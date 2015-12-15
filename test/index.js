/**
 * Test
 * @author: SimonHao
 * @date:   2015-12-08 10:32:11
 */

'use strict';
var fs = require('fs');
var Parser = require('../index.js');

var filename = __dirname + '/layout.jade';
var str = fs.readFileSync(filename, 'utf-8');

var parser = new Parser(str, filename);

console.log(JSON.stringify(parser.parse()));