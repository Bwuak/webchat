import {DOM} from "./views/app_view" 
import State from "./models/state"


function has_changed(n1, n2) {
  return n1 == n2
}

let hooksInitializer = (function(state) {
  let Hooks = {}

  Hooks.Chatroom = {
    mounted() {
      console.log("chatroom change")
    },
  
    updated() {
      console.log("updated chatroom")
      /*
      const chatroomId = DOM.getCurrentChatroomId()
      const serverId = DOM.getCurrentServerId()
      const chatroom = state.getChatroom(serverId, chatroomId) 
      DOM.renderChatroom(chatroom)
      */
    }
  }

  return {
    Hooks: Hooks
  }
})


export default hooksInitializer 
