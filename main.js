#!/usr/bin/env node
const commandLineArgs = require('command-line-args')
const ndf = require('./ndf')

const optionDefinitions = [
  { name: 'header', alias: 'e', type: Boolean },
  { name: 'src', type: String, defaultOption: true }
]

const options = commandLineArgs(optionDefinitions)

const actual= ndf.get(options.src)

if (options.header)
  ndf.header()

ndf.write(actual)
