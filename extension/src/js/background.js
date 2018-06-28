import '../img/icon-128.png'
import '../img/icon-34.png'

import NervosWeb3 from '@nervos/web3'

const web3 = connectChain()

let account = getAccount()

chrome.runtime.onMessage.addListener(
  function (request, sender, sendResponse) {
    if (request.type === 'message') {
      if (request.data.type === 'sendTransaction') {
        const { msg: txStr, id } = request.data
        const tx = JSON.parse(txStr)
        if (!account) {
          account = getAccount()
        }
        tx.privkey = account.privateKey
        web3.eth.sendTransaction(tx).then((res) => {
          const s = JSON.stringify({type: 'sendTransaction',id: id,msg: res.result,from: 'popup'})
          sendResponse(s)
        })

        return true
      }
    }
  }
);

function connectChain(accounts) {
  const chain = 'http://47.97.108.229﻿:1337'
  const web3 = NervosWeb3(chain)

  return web3
}


function getAccount() {
  return JSON.parse(localStorage.getItem("account0"))
}
