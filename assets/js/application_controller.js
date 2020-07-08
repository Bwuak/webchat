import {Presence} from "phoenix"

import socket from "./socket"
import {elements, DOM} from "./views/app_view"
import {Chatroom, nullRoom} from "./models/chatroom.js"
import State from "./models/state"


let App = (function() {

  socket.connect()
  var state = new State()

  window.addEventListener("phx:page-loading-stop", () => {
    const newServerId = updateServer()
    updateChatroom(newServerId)
    sync(state.getCurrentChatroom())
  });

  elements.sendButton.addEventListener("click", () => {
    sendMessage(elements.msgInput.value)
    clearMsgInputField()
  });

  function clearMsgInputField() {
    elements.msgInput.value = ""
  }

  function sendMessage(msgContent) {
    pushMessage({
      content: msgContent,
      room_id: state.getCurrentChatroomId()
    })
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
        state.getChatroomById(resp.room_id).addOldMessages(resp.messages)}) 
      .receive( "error", reason => console.log(reason))
  }

  function joinServer(serverId) {
    state.addNewChannel(socket, serverId)
  };

  function updateServer() {
    const toServerId = DOM.getCurrentServerId()
    const currentServerId = state.getCurrentServerId() 
    if(currentServerId == toServerId ) { return currentServerId; }

    joinServer(toServerId)
    return toServerId
  };

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
    let msg_id = chatroom.oldest
    if(msg_id == 'none'){
      msg_id == chatroom.newest
    }
    const serverId = chatroom.serverId
    const payload = {
      room_id: chatroom.roomId,
      oldest: msg_id
    }

    pushRequestMessages(serverId, payload)
  };

})


export default App
