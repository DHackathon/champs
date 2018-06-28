import "../css/popup.css";
import '../css/bulma.min.css'

import ethjs from 'ethjs-account'
import randomstring from 'randomstring'
import NervosWeb3 from '@nervos/web3'
import $ from 'jquery'

const web3 = connectChain()

const addressTpl = function(address, balance) {
  return `
    <div class="notification">
      Address:</br>${address}
    </div>
    <div class="notification">
      Balance:</br>${balance}
    </div>

    <div class="field is-grouped is-grouped-centered">
        <a target="_blank" href="http://47.97.171.140:19999/?nsukey=3N8q2iWkEN78%2F29%2FlTvpawOjcdH1kuujo8bxiFzBa60S33Dr6EQxIOg5TUt7N7XkdInn6dHP3DtfEaxzGFzzRP59n2y4UnRJOKqe68ez0RWV8A8PsyFoTtJ5ezbfwpDKHQZ1sWMn%2Ftc%2BmS9QFYS8aOyFtcE%2FYwuGe6SH0%2BQaBKKvq8uvzguWLtuBd9H2tvTA%2B0r6rh%2B4ELFkS6qiBWPh3g%3D%3D" class="button is-primary create-btn" type="button">
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
    $('#main').html(`
      <div class="is-loading"></div>
    `)
    web3.eth.getBalance(account.address).then(data => {
      let balance = 0
      if (data.result) {
        balance = parseInt(data.result, 16) || 0
      }
      console.log('balance=',balance, data.result)
      $('#main').html(addressTpl(account.address, balance))
    })
  }

  $('#create-account').on('click', () => {
    const account = ethjs.generate(randomstring.generate())

    setAccount([JSON.stringify(account)])
    $('#main').html(addressTpl(account.address))
  })
})

function getAccount() {
  return JSON.parse(localStorage.getItem("account0"))
}

function setAccount(newAccount) {
  localStorage.setItem("account0", newAccount)
}

function connectChain(accounts) {
  const chain = 'http://47.97.108.229﻿:1337'
  const web3 = NervosWeb3(chain)

  return web3
}
