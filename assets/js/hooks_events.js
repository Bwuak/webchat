import {DOM} from "./views/app_view" 
import State from "./models/state"

function updateChatroom(state) {
  const chatroom = state
    .getChatroom(DOM.getCurrentServerId(), DOM.getCurrentChatroomId())
  state.setCurrentChatroom(chatroom)
  DOM.renderChatroom(chatroom)
}

let hooksInitializer = (function(state, requests, socket) {
  let Hooks = {}

  Hooks.Chatroom = {
    // Chatroom change 
    mounted() {
      updateChatroom(state)
      requests.requestMessages(state.getCurrentChatroom() )
    },

    updated() {
      updateChatroom(state)
      requests.requestMessages(state.getCurrentChatroom() )
    },
  }


  Hooks.Server = {
    mounted() {
      // subscribe to servers
      const servers = DOM.getAllServersId()
      servers.forEach( id => requests.joinServerChannel(id) )

      // set current server
      const serverId = DOM.getCurrentServerId()
      state.setCurrentServerId( serverId ) 
    },

    // Server change
    updated() {
      const serverId = DOM.getCurrentServerId()
      state.setCurrentServerId( serverId ) 
    },

  }

  return {
    Hooks: Hooks
  }
})


export default hooksInitializer 
