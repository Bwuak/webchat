import {DOM} from "./views/app_view" 
import State from "./models/state"


let hooksInitializer = (function(state, requests) {
  let Hooks = {}

  Hooks.Chatroom = {
    // Chatroom change 
    mounted() {
      const chatroom = state
        .getChatroom(DOM.getCurrentServerId(), DOM.getCurrentChatroomId())

      DOM.renderChatroom(chatroom)
      requests.requestMessages(chatroom)
    },

    updated() {
      console.log("update")
      const toRoomId = DOM.getCurrentChatroomId()
      const serverId = DOM.getCurrentServerId()
      const chatroom = state.getChatroom(serverId, toRoomId)

      state.setCurrentChatroom(chatroom)
      DOM.renderChatroom(chatroom)
      requests.requestMessages(chatroom)
    },
  }


  Hooks.Server = {
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
