import {DOM} from "./views/app_view" 
import State from "./models/state"



let hooksInitializer = (function(state) {
  let Hooks = {}

  Hooks.Chatroom = {
    // Chatroom change 
    updated() {
      const toRoomId = DOM.getCurrentChatroomId()
      const serverId = DOM.getCurrentServerId()
      const chatroom = state.getChatroom(serverId, toRoomId)

      state.setCurrentChatroom(chatroom)
      DOM.renderChatroom(chatroom)
    },
  }

  return {
    Hooks: Hooks
  }
})


export default hooksInitializer 
