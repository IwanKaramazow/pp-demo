#!/usr/bin/env node
//@ts-check
var fs = require('fs')
var fileName = process.argv[2]
console.warn(process.argv,fileName,'hi')
var file = fs.readFileSync(fileName, 'utf8')
var newContent = "type 'a foo = Foo of a"
console.warn(newContent)
console.log(newContent)
