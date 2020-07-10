import {Presence} from "phoenix"
import regeneratorRuntime from "regenerator-runtime"

import {elements, DOM} from "./views/app_view"
import {Chatroom, nullRoom} from "./models/chatroom.js"
import State from "./models/state"



let App = (function(socket) {

  
  socket.connect()
  var state = new State()

  setInterval(scrolldown, 50)

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

  elements.msgContainer
  elements.sendButton.addEventListener("click", () => {
    sendMessage()
  });

  function scrolldown() {
    var div = document.getElementById("messages-container")
    //if(isChatScrollLocked(div)){
      div.scrollTop = div.scrollHeight
    //}
  }

  // function isChatScrollLocked(div) {
  //   return div.scrollTopMax - (div.clientHeight/3) < div.scrollTop  
  // }

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

    leaveServer()
    joinServer(toServerId)
    return toServerId
  };

  function leaveServer() {
    state.deletePresence()
  }

  function joinServer(serverId) {
    var channel = state.getChannelById(serverId)
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

    pushRequestMessages(chatroom.serverId, payload)
  };

})


export default App