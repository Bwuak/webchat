// could remove DOM dependency by using 
// *this* inside hooks, but we'd need to add datasets
// in html
import DOM from "./views/app_view" 
import Controller from "./chat_controller"



function updateChatroom() {
  Controller.updateChatroom(
    DOM.getCurrentServerId(),
    DOM.getCurrentChatroomId()
  )
}

let hooksInitializer = (function() {
  let Hooks = {}

  Hooks.Chatroom = {
    mounted() {
      updateChatroom()
    },

    updated() {
      updateChatroom()
    },
  }


  Hooks.Server = {
    mounted() {
      console.log("mounted")
      const servers = DOM.getAllServersId()
      Controller.joinServers(servers)

      const serverId = DOM.getCurrentServerId()
      Controller.joinServer(serverId)
    },

    updated() {
      console.log("updated")
      const serverId = DOM.getCurrentServerId()
      Controller.joinServer( serverId ) 
    },

  }


  return {
    Hooks: Hooks
  }
})()


export default hooksInitializer 
