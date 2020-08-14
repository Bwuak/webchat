import State from "./models/state"
import DOM from "./views/app_view"
import WebchatRequests from "./webchat_requests"


var scroll = {
  state: "locked"
}

setInterval(() => {
  if(scroll.state == "locked"){
    scrolldown()
  }
}, 50)

function scrolldown() {
  var div = document.getElementById("messages-container")
  div.scrollTop = div.scrollHeight
}

setTimeout(scrolldown, 5)



const controller = {
  sendMessage: (msgContent) => {
    WebchatRequests.sendMessage(msgContent)
  },

  updateChatroom: (serverId, chatroomId) => {
    // state update
    const chatroom = State.getChatroom(serverId, chatroomId)
    State.setCurrentChatroom(chatroom)
  
    // DOM update
    DOM.renderChatroom(chatroom)
    scrolldown()

    WebchatRequests.requestMessages(State.getCurrentChatroom() )
  },

  scrollMoved: (height, scrollTop, clientHeight) => {
    if(height - scrollTop == clientHeight) {
      scroll.state = "locked"
    }else{
      scroll.state = "unlocked"
    }
  },

  joinServers: (serversIds) => {
    serversIds.forEach( id => WebchatRequests.joinServerChannel(id) )
  },

  joinServer: (id) => {
    State.setCurrentServerId = id
  }

}


export default controller
