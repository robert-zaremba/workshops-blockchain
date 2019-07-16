// @flow
const blake2 = require('blake2')
const bodyParser = require('body-parser')
const express = require('express')
// require('express-async-errors')

const storeHash = require('./blockchain')

async function docHandler (req, res) {
  // TODO: record the sender id

  let docHash = blake2.createHash('blake2b', {digestLength: 32})
    .update(Buffer.from(req.body))
    .digest()
  let txReceipt = await storeHash(docHash)

  res.status(200).json({
    len: docHash.length,
    hash: docHash,
    txReceipt
  })
}

const app = express()
app.use(bodyParser.urlencoded({ extended: true }))
app.use(bodyParser.text())

app.post('/record-document', docHandler)
app.listen(3000)

// curl -X POST -d @file.txt http://localhost:3000/record-document -H "Content-Type: text/plain"
