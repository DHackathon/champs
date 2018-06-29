import "../css/popup.css";
import '../css/bulma.min.css'
import '../css/bulma-pageloader.min.css'

import ethjs from 'ethjs-account'
import randomstring from 'randomstring'
import NervosWeb3 from '@nervos/web3'
import $ from 'jquery'
import BigNumber from 'bignumber.js'

import { chainURL } from './constant'
const web3 = connectChain(chainURL)

const addressTpl = function(address, balance) {
  return `
    <div class="notification">
      Address:</br>${address}
    </div>
    <div class="notification">
      Balance:</br>${balance}
    </div>

    <div class="field is-grouped is-grouped-centered">
        <a target="_blank" href="http://47.97.171.140:19998" class="button is-primary create-btn" type="button">
          领代币
        </a>
    </div>
  `
}

$(() => {
  const account = getAccount()
  if (!account) {
    $('#main').html(`
      <div class="field is-grouped is-grouped-centered">
          <button id="create-account" class="button is-primary create-btn" type="button">
            Create Account
          </button>
      </div>
    `)
  } else {
    let val = ""
    if (location.search) {
      val = decodeURIComponent(location.search.substring(4, location.search.length))

    }
    if (val) {
      try {
        const tx = JSON.parse(val)
        setTxFields(tx)
        $('#send-btn').on('click', () => {
          postMessage({ type: 'checkTx', status: 'ok'}, '*')
          $('#main').html(`
            <div id="pageloader" class="pageloader is-active"><span class="title">Loading</span></div>
          `)

          txRes()
        })
        $('#close-btn').on('click', () => {
          postMessage({ type: 'checkTx', status: 'reject'}, '*')
          window.close()
        })
      } catch (e) {

      }
    } else {
      $('#main').html(`
        <div id="pageloader" class="pageloader is-active"><span class="title">Loading</span></div>
      `)
      web3.eth.getBalance(account.address).then(data => {
        let balance = 0
        if (data.result) {
          balance = new BigNumber(data.result).toString()
        }

        $('#main').html(addressTpl(account.address, balance))
      })
    }
  }

  $('#create-account').on('click', () => {
    const account = ethjs.generate(randomstring.generate())

    setAccount([JSON.stringify(account)])
    $('#main').html(addressTpl(account.address))
  })

  chrome.runtime.onMessage.addListener(
    function(request, sender, sendResponse) {
      if (isSendPopup(request)) {
        if (request.type === 'checkTransaction') {
          if (`?time=${request.time}` === location.search) {
            console.log('checkTransaction')
          }
        }

        return true
      }
    }
  );
})

function getAccount() {
  return JSON.parse(localStorage.getItem("account0"))
}

function setAccount(newAccount) {
  localStorage.setItem("account0", newAccount)
}

function connectChain(chainURL) {
  const web3 = NervosWeb3(chainURL)

  return web3
}

function isSendPopup(request = {}) {
  const to = request.to
  return to === 'popup'
}

function setTxFields(tx) {
  $('#send-tx-modal').addClass('is-active')
  $('#tx-to-input').val(tx.to)
  $('#tx-value-input').val(tx.value)
  $('#tx-nonce-input').val(tx.nonce)
  $('#tx-quota-input').val(tx.quota)
  $('#tx-data-input').val(tx.data)
}

function txRes() {
  setTimeout(() => {
    const val = $('#txRes').val()
    if (val) {
      const data = JSON.parse(JSON.parse(val).data).msg
      if (data.error) {
        $('#container'),html(`
          <section class="hero is-fullheight is-danger is-bold">
            <div class="hero-body">
              <div class="container">
                <h1 class="title">
                  Error
                </h1>
                <h2 class="subtitle">
                  ${data.error}
                </h2>
              </div>
            </div>
          </section>
        `)
      } else {
        $('#container').html(`
          <section class="hero is-fullheight is-success is-bold">
            <div class="hero-body">
              <div class="container">
                <h1 class="title">
                  Success
                </h1>
                <h2 class="subtitle">
                  ${data.hash}
                </h2>
              </div>
            </div>
          </section>
        `)
      }

      $('#send-tx-modal').removeClass('is-active')
    } else {
      txRes()
    }
  }, 500)
}
