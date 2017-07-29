const moment = require('moment')
const path = require('path')
const fs = require('fs')

function get(dirname) {
  return fs.readdirSync(dirname)
  .filter(filename => filename.match(/^[0-9]{8}-ndf-repas-[0-9]{3,4}.jpg$/))
  .sort()
  .map((filename) => {
    const splitted = path.basename(filename, '.jpg').split(/[-.]/)
    return {
      date: moment(splitted[0], 'YYYYMMDD').format('DD/MM/YYYY'),
      type: splitted[2],
      amount: parseInt(splitted[3]) / 100
    }
  })
}

function header() {
  process.stdout.write('date;type;amount\n')
}

function write(notes) {
  notes.forEach(note => process.stdout.write(`${note.date};${note.type};${note.amount}\n`))
}

module.exports = {
  get,
  write,
  header
}
