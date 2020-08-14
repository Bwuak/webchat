import regeneratorRuntime from "regenerator-runtime"

import DOM from "./views/app_view"
import Controller from "./chat_controller"


let events = (function() {
  /* 
  * gets the logout link from the layout 
  * because it can logout the conn's session 
  * ---
  *  Until I search for a solution
  */
  const link = document.getElementById("if-anyone-knows-how-to-fix-this-tell-me-please")
  const linkContainer = document.getElementById("link-container")
  linkContainer.appendChild(link)

  DOM.sendButton.addEventListener("click", () => {
    sendMessage()
  });

  DOM.msgInput.onkeyup = function(e) {
    if(e.keyCode == 13) {
      sendMessage()
    }
  }

  const div = document.getElementById("messages-container")
  div.addEventListener("scroll", function() {
    Controller.scrollMoved(div.scrollHeight, div.scrollTop, div.clientHeight)
  });

  function clearMsgInputField() {
    DOM.msgInput.value = ""
  }

  function sendMessage() {
    const msgContent = DOM.msgInput.value.trim()
    Controller.sendMessage(msgContent)
    clearMsgInputField()
  }

})()


export default events 
