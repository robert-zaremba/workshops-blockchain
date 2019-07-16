// @flow

var sdk = require('stellar-sdk')
sdk.Network.useTestNetwork()
var srv = new sdk.Server('https://horizon-testnet.stellar.org')

var alice = 'GDOVAOCSCI77D2KLMBS62MYEB3PP6NYXTIRGCJ4UMSWWSGXYU2GKERHY'
var bob   = 'GBYMAPLITJ2LF5SXKH7NMMHTYVK5PELYW5N5DO7NKNHUY64PBGG5FYIX'

var builder = srv.transactions().forAccount(alice)

sdk.S


// Object with `records`, `prev`, `next`
builder.call()

// One message per record
var es = builder.stream({ onmessage: console.log })

srv.offers().forLedger(7891202).call().then(console.log)

var src = new sdk.Account(alice, "12345")

var tx = new sdk.TransactionBuilder(src)
tx.addOperation(sdk.Operation.payment({
  destination: bob,
  asset: sdk.Asset.native(),
  amount: "123.456"
}))

srv.loadAccount(alice).then(function (acc) {
  return new sdk.TransactionBuilder(acc._baseAccount).build()
})
