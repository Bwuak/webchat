import {Presence} from "phoenix"

import socket from "./socket"
import {elements, DOM} from "./views/app_view"
import Chatroom from "./models/chatroom.js"

const nullRoom = {
  chatroom: {
    roomId: 'none',
    messages: []
  }
}

let App = (function() {

  socket.connect()

  const STATE = {
    channels: {},
    chatrooms: {},
    currentChatroom: nullRoom
  };

  // listens to liveview live patching
  // updates server and chatroom if needed
  window.addEventListener("phx:page-loading-stop", () => {
    updateServer()
    updateChatroom(STATE.serverId)
  });

  elements.sendButton.addEventListener("click", () => {

    sendMessage(elements.msgInput.value)
    clearMsgInputField()
  });

  function clearMsgInputField() {
    elements.msgInput.value = ""
  }

  function getCurrentChannelId() {
    return getCurrentChatroom().serverId
  }

  function getCurrentChatroomId() {
    return getCurrentChatroom().roomId
  }

  function getCurrentChatroom() {
    return STATE.currentChatroom
  }

  function sendMessage(msgContent) {
    const payload = {
      content: msgContent, 
      room_id: getCurrentChatroomId() 
    }

    pushMessage(payload)
  }

  function pushMessage(payload) {
    const channelId = getCurrentChannelId()
    STATE.channels[channelId].push("new_message", payload)
      .receive("error", e => console.log(e))
  }




  var joinServer = function(serverId) {
    const channel = socket.channel("server:" + serverId, () => {})
    const presence = new Presence(channel)
    STATE.channels[serverId] = channel

    channel.join()
      .receive("ok", resp => {
        presence.onSync(() => {
          elements.userListContainer.innerHTML = presence.list((id, 
          {user: user, metas: [first, ...rest]}) => {
          return `<p>${user.username}</p>`
          }).join("")
        })
      })
      .receive("error", reason => console.log(reason))
    
    channel.on("new_message", resp => {
      STATE.chatrooms[resp.message.room_id].addNewMessage(resp.message)
    })
  };

  var leaveServer = function(serverId) {
    if( ! STATE.channels[serverId] ) { return; }
    STATE.channels[serverId].leave()
    delete STATE.channels[serverId]
  };

  var updateServer = function() {
    const toServerId = DOM.getCurrentServerId()
    const currentServerId = STATE.currentChatroom.serverId
    if(currentServerId == toServerId ) { return; }

    leaveServer(currentServerId)
    joinServer(toServerId)
    STATE.serverId = toServerId
  };

  var updateChatroom = function(serverId) {
    const toChatroomId = DOM.getCurrentChatroomId()
    const noChange = STATE.currentChatroom.roomId == toChatroomId
    if(noChange) { return; }
    
    const chatroom = joinChatroom(toChatroomId, serverId)
    DOM.renderChatroom(chatroom)
  };

  var joinChatroom = function(roomId, serverId) {
    if( ! roomId ) { 
      return nullRoom
    }

    let currentRoom = STATE.chatrooms[roomId]
    if(! currentRoom) {
      currentRoom = new Chatroom(serverId, roomId)
      STATE.chatrooms[roomId] = currentRoom
    }

    if(currentRoom.getMessagesCount() < 50) {
      requestMessages(currentRoom)
    }
    STATE.currentChatroom = currentRoom
    return currentRoom
  };

  var requestMessages = function(chatroom) {
    let msg_id = chatroom.oldest
    if(msg_id == 'none'){
      msg_id == chatroom.newest
    }
    const serverId = chatroom.serverId
    const payload = {
      room_id: chatroom.roomId,
      oldest: msg_id
    }

    STATE.channels[serverId].push("request_messages", payload)
      .receive( "ok", resp => {
        STATE.chatrooms[resp.room_id].addOldMessages(resp.messages)}) 
      .receive( "error", reason => console.log(reason))
  };

})


export default App
