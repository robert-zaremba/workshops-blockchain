// @flow

const StellarSdk = require('stellar-sdk')

StellarSdk.Network.useTestNetwork()
var server = new StellarSdk.Server('https://horizon-testnet.stellar.org')

const publicKey = 'G...'
const privKey = 'S...'

const receiverAddr = 'G...'

async function storeHash (body) {
  let account = await server.loadAccount(publicKey)
  var tx = new StellarSdk.TransactionBuilder(account)
    .addOperation(StellarSdk.Operation.payment({
      destination: receiverAddr,
      // for workshop we will use XLM, but we should use other specific coins
      asset: StellarSdk.Asset.native(),
      // Lumens are divisible to seven digits past the decimal.
      amount: '0.00003'
    }))
    .addMemo(StellarSdk.Memo.hash(body))
    .build()

  const keypair = StellarSdk.Keypair.fromSecret(privKey)
  tx.sign(keypair)
  let resp = await server.submitTransaction(tx)
  console.log('Transaction submitted successfully', resp)
  return resp
}

module.exports = storeHash
