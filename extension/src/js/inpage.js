import NervosWeb3 from '@nervos/web3'
import EventEmitter from 'events'
import { chainURL } from './constant'

const web3 = NervosWeb3(chainURL)

const event = new EventEmitter()
window.event = event

let requestID = 1
web3.eth.sendTransaction = function(tx) {
  requestID += 1
  const id = requestID
  window.postMessage({type:'sendTransaction', msg: JSON.stringify(tx), id: id}, '*');
  return new Promise((resolve, reject) => {
    event.on(id, (msg) => {
      if (msg.error) {
        return reject(msg.error)
      }
      console.log(msg)
      return resolve(msg)
    })
  })
}

window.addEventListener('message',(e) => {
  if (e.source != window) {
    return
  }

  event.emit(e.data.id, e.data.msg)
})
window.nervosweb3 = web3
