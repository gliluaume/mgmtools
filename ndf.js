const moment = require('moment')
const path = require('path')
const fs = require('fs')

const sep = ';'

function get(dirname) {
  return fs.readdirSync(dirname)
  .filter(filename => filename.match(/^[0-9]{8}-[a-z]*-[a-zA-Z]*-[0-9]{3,7}.[a-z]{3}$/))
  .map((filename) => {
    const splitted = path.parse(filename).name.split(/[-.]/)
    return {
      date: moment(splitted[0], 'YYYYMMDD'),
      type: splitted[1],
      title: splitted[2],
      amount: parseInt(splitted[3]) / 100
    }
  })
  .sort((da, db) => da.date - db.date)
  .map(data => ({
      date: data.date.format('DD/MM/YYYY'),
      type: data.type,
      title: data.title,
      amount: data.amount
    }))
}

function header(culture) {
  const cult = culture || 'fr'
  const heads = {
    'en': [
      'date',
      'type',
      'title',
      'amount'
      ],
    'fr': [
      'date',
      'type',
      'titre',
      'montant'
      ]
  }
  process.stdout.write(`${heads[cult].join(sep)}\n`)
}

function write(notes) {
  notes.forEach(note => process.stdout.write(`${note.date}${sep}${note.type}${sep}${note.title}${sep}${note.amount}\n`))
}

module.exports = {
  get,
  write,
  header
}
