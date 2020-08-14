import {Presence} from "phoenix"
import regeneratorRuntime from "regenerator-runtime"

import {elements, DOM} from "./views/app_view"
import {Chatroom, nullRoom} from "./models/chatroom.js"


let App = (function(state, requests) {

  var scroll = {
    state: "locked"
  }

  setInterval(() => {
    if(scroll.state == "locked"){
      scrolldown()
    }
  }, 50)

  /* hack so user can log out from it's conn session 
  *  Was not able to find conn in liveview socket
  *  Was not able to find a replacement for link in liveview
  */
  const link = document.getElementById("if-anyone-knows-how-to-fix-this-tell-me-please")
  const linkContainer = document.getElementById("link-container")
  linkContainer.appendChild(link)

  

  elements.msgInput.onkeyup = function(e) {
    if(e.keyCode == 13) {
      const msgContent = elements.msgInput.value.trim()
      requests.sendMessage(msgContent)
      clearMsgInputField()
    }
  }

  setTimeout(scrolldown, 5)

  const div = document.getElementById("messages-container")
  div.addEventListener("scroll", function() {
    if(div.scrollHeight - div.scrollTop == div.clientHeight) {
      scroll.state = "locked"
    }else{
      scroll.state = "unlocked"
    }
  });

  elements.sendButton.addEventListener("click", () => {
    const msgContent = elements.msgInput.value.trim()
    requests.sendMessage(msgContent)
    clearMsgInputField()
  });

  function scrolldown() {
    var div = document.getElementById("messages-container")
    div.scrollTop = div.scrollHeight
  }

  function clearMsgInputField() {
    elements.msgInput.value = ""
  }


})


export default App
