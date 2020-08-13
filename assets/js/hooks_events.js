import {DOM} from "./views/app_view" 
import State from "./models/state"



let hooksInitializer = (function(state) {
  let Hooks = {}

  Hooks.Chatroom = {
    mounted() {
      console.log("chatroom change")
    },
  
    // chatroom had an update
    updated() {
      console.log("updated chatroom")
      const fromChatroomId = state.getCurrentChatroomId()
      const toRoomId = DOM.getCurrentChatroomId()

      const hasChanged = fromChatroomId == toRoomId

      if(hasChanged) {
        const chatroom = state.getChatroom(toRoomId)
        state.setCurrentChatroom(chatroom)

        const serverId = DOM.getCurrentServerId()
        DOM.renderChatroom(serverId, chatroom)
      }
    }
  }

  return {
    Hooks: Hooks
  }
})


export default hooksInitializer 
