import {Presence} from "phoenix"
import regeneratorRuntime from "regenerator-runtime"

import {elements, DOM} from "./views/app_view"
import {Chatroom, nullRoom} from "./models/chatroom.js"
import State from "./models/state"



let App = (function(socket) {

  
  socket.connect()
  var state = new State()
  var scroll = {
    state: "locked"
  }

  setInterval(() => {
    if(scroll.state == "locked"){
      scrolldown()
    }
  }, 50)

  // hack to log out
  // Was not able to find conn in liveview socket
  // Was not able to find a replacement for link in liveview
  const link = document.getElementById("if-anyone-knows-how-to-fix-this-tell-me-please")
  const linkContainer = document.getElementById("link-container")
  linkContainer.appendChild(link)


  document.onkeyup = function(e) {
    if(e.keyCode == 13) {
      sendMessage()
    }
  }

  window.addEventListener("phx:page-loading-stop", () => {
    const newServerId = updateServer()
    updateChatroom(newServerId)
    sync(state.getCurrentChatroom())
  });


  const div = document.getElementById("messages-container")
  div.addEventListener("scroll", function() {
    scroll.state = "unlocked"
    if(div.scrollTopMax - div.scrollTop < 1) {
      scroll.state = "locked"
    }else{
      scroll.state = "unlocked"
    }
  });

  elements.sendButton.addEventListener("click", () => {
    sendMessage()
  });

  function scrolldown() {
    var div = document.getElementById("messages-container")
    div.scrollTop = div.scrollHeight
  }

  function clearMsgInputField() {
    elements.msgInput.value = ""
  }

  function sendMessage() {
    pushMessage({
      content: elements.msgInput.value,
      room_id: state.getCurrentChatroomId()
    })
    clearMsgInputField()
  }

  function pushMessage(payload) {
    const channel = state.getChannel()
    channel.push("new_message", payload)
      .receive("error", e => console.log(e))
  }

  function pushRequestMessages(serverId, payload) {
    const channel = state.getChannelById(serverId)
    channel.push("request_messages", payload)
      .receive( "ok", resp => {
        state.getChatroomById(resp.room_id).addOldMessages(resp.messages)
      }) 
      .receive( "error", reason => console.log(reason))
  }

  function updateServer() {
    const toServerId = DOM.getCurrentServerId()
    const currentServerId = state.getCurrentServerId() 
    if(currentServerId == toServerId ) { return currentServerId; }

    leaveServer(currentServerId)
    joinServer(toServerId)
    return toServerId
  };

  function leaveServer(currentServerId) {
    //state.deletePresence()
    if(state.getChannelById(currentServerId)) {
      state.getChannelById(currentServerId).leave()
      delete state.getChannelById(currentServerId)
    }
  }

  function joinServer(serverId) {
    //var channel = state.getChannelById(serverId)
    var channel;
    if( ! channel ) {
      channel = createChannel(socket, serverId)
    }
    const presence = new Presence(channel)

    presence.onSync(() => {
      elements.userListContainer.innerHTML = presence.list((id, 
      {user: user, metas: [first, ...rest]}) => {
      return `<p>${user.username}</p>`
      }).join("")
    })

    state.setCurrentPresence(presence, serverId)
  };

  function createChannel(socket, serverId){
    const channel = socket.channel("server:" + serverId, () => {})
    channel.join()
      .receive("error", reason => console.log(reason))
    channel.on("new_message", resp => {
      state.getChatroomById([resp.message.room_id]).addNewMessage(resp.message)
    })

    state.addNewChannel(channel, serverId)
    return channel
  }

  function updateChatroom(serverId) {
    const toChatroomId = DOM.getCurrentChatroomId()
    const noChange = state.getCurrentChatroomId() == toChatroomId
    if(noChange) { return; }
    
    const chatroom = getNewChatroom(serverId, toChatroomId)
    state.setCurrentChatroom(chatroom)
    DOM.renderChatroom(chatroom)
  };

  function getNewChatroom(serverId, roomId) {
    const room = state.getChatroomById(roomId)
    return  room != nullRoom ?
      room : state.createChatroom(serverId, roomId)
  };

  function sync(currentRoom) {
    if(currentRoom.getMessagesCount() < 50) {
      requestMessages(currentRoom)
    }
  }

  function requestMessages(chatroom) {
    const payload = {
      room_id: chatroom.roomId,
    }

    if(chatroom.oldest){
      payload.oldest = chatroom.oldest
    }else if(chatroom.newest) {
      payload.oldest = chatroom.newest
    }// else payload.oldest is not set

    // temp fix for now
    if(chatroom.newest) {
      payload.oldest = chatroom.newest
    }
    pushRequestMessages(chatroom.serverId, payload)
  };

})


export default App
