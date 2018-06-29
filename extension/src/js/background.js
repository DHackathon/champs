import '../img/icon-128.png'
import '../img/icon-34.png'

import NervosWeb3 from '@nervos/web3'
import { chainURL } from './constant'

const web3 = connectChain(chainURL)

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

        const time = Date.now()
        const childPage = window.open(`popup.html?tx=${txStr}`, "extension_popup", "width=490px,height=520px,status=no,scrollbars=yes,resizable=no")
        childPage.addEventListener('message', e => {
          if (e.data && e.data.type === 'checkTx') {
            if (e.data.status === 'ok') {
              tx.privkey = account.privateKey
              tx.from = account.address
              web3.eth.sendTransaction(tx).then((res, err) => {
                console.log('background res ', res, err)
                const s = JSON.stringify({type: 'sendTransaction',id: id,msg: res.result,from: 'popup'})
                sendResponse(s)
                const input = childPage.document.getElementById('txRes')
                input.value = JSON.stringify({ type: 'txRes', data: s })
              })
            } else if (e.data.status === 'reject') {
              const s = JSON.stringify({type: 'sendTransaction',id: id,msg: { error: 'reject'},from: 'popup'})
              sendResponse(s)
            }
          }
        })

        return true
      }
    }
  }
);

function connectChain(chainURL) {
  const web3 = NervosWeb3(chainURL)

  return web3
}

function getAccount() {
  return JSON.parse(localStorage.getItem("account0"))
}
