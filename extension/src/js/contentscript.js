function injectScript(file) {
    var s = document.createElement('script');
    s.setAttribute('type', 'text/javascript');
    s.setAttribute('src', file);
    document.body.appendChild(s)
}
document.addEventListener('DOMContentLoaded', () => {
    injectScript(chrome.extension.getURL('/inpage.bundle.js'));
})

window.addEventListener("message", function (event) {
  if (event.source != window) {
    return;
  }

  chrome.runtime.sendMessage({type: event.type, data: event.data}, function(response) {
    try {
      const res = JSON.parse(response)
      if (res && res.from === 'popup') {
        window.postMessage(res, '*')
      }
    }catch(err){

    }
  })
}, false);
