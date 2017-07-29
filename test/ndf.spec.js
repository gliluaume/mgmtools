const assert = require('assert')
const ndf = require('../ndf')

const actual = ndf.get(__dirname + '/data')

assert.equal(actual.length, 3, 'give 3 result')
assert.equal(actual[0].date, '19/07/2017', 'date is a string representing a date')
assert.equal(actual[1].date, '20/07/2017', 'second is on its place')
assert.equal(actual[2].date, '24/07/2017', 'third is on its place')
assert.deepEqual(actual[0], { date: '19/07/2017', type: 'repas', amount: 10.5 }, 'whole info parsed')

ndf.write(actual)
