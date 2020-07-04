// Fetch messages from STATE
//   -> < 50 fetch messages from server
// add received messages to STATE
// must identify each message
// must use message date to not duplicate them
//
// chatroom class?? has
// list of messages
// id of chatroom
// first message
// last message
// add before, add after..
//
//
// controller 
// - adding messages to STATE
// - has one active chatroom in STATE
// - has one active server in STATE?
import {Presence} from "phoenix"

import socket from "./socket"
import {elements, DOM} from "./views/app_view"
import Chatroom from "./models/chatroom.js"

let App = (function() {

  socket.connect()
  const STATE = {
    channels: {},
    chatrooms: {},
    currentServerId: 'none',
    currentChatroomId: 'none',
  };

  elements.sendButton.addEventListener("click", () => {
    const channelId = STATE.currentServerId
    const roomId = STATE.currentChatroomId
    const payload = {
      content: elements.msgInput.value,
      room_id: roomId 
    }

    STATE.channels[channelId].push("new_message", payload)
      .receive("error", e => console.log(e))
    elements.msgInput.value = ""
  });

  // listens to liveview live patching
  // updates server and chatroom if needed
  window.addEventListener("phx:page-loading-stop", () => {
    updateServer()
    updateChatroom()
    console.log(STATE)
  });

  // This should be in app_view.js 
  // But I don't want to import Presence there
  var renderUserList = function(presence) {
    elements.userListContainer.innerHTML = presence.list((id, 
      {user: user, metas: [first, ...rest]}) => {
      return `<p>${user.username}</p>`
    }).join("")
  };

  var joinServer = function(serverId) {
    const channel = socket.channel("server:" + serverId, () => {})
    const presence = new Presence(channel)

    channel.join()
      .receive("ok", resp => {
        presence.onSync(() => {
          renderUserList(presence) 
        })
      })
      .receive("error", reason => console.log(reason))
    
    channel.on("new_message", resp => {
      DOM.renderNewMessage(resp.message)
    })

    STATE.channels[serverId] = channel
    STATE.currentServerId = serverId
    STATE.presence = presence
  };

  var leaveServer = function(serverId) {
    if( ! STATE.channels[serverId] ) { return; }
    STATE.channels[serverId].leave()
    delete STATE.channels[serverId]
  };

  var updateServer = function() {
    const toServerId = DOM.getCurrentServerId()
    if(STATE.currentServerId == toServerId ) { return; }

    leaveServer(STATE.currentServerId)
    joinServer(toServerId)
  };

  var updateChatroom = function() {
    const toChatroomId = DOM.getCurrentChatroomId()
    const noChange = STATE.currentChatroomId == toChatroomId
    if(noChange) { return; }
    
//    DOM.clearMessages()
    joinChatroom(toChatroomId, STATE.currentServerId)
  };

  var joinChatroom = function(roomId, serverId) {
    if( ! roomId ) {
      STATE.currentChatroomId = 'none'
      return
    }

    let current_room = STATE.chatrooms[roomId]
    if(! current_room) {
      current_room = new Chatroom(serverId, roomId)
      STATE.chatrooms[roomId] = current_room
    }

    STATE.currentChatroomId = serverId 
    if(current_room.getMessagesCount() < 50) {
      requestMessages(current_room)
    }
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
        STATE.chatrooms[resp.room_id].addOldMessages(resp.messages)
        if(STATE.currentChatroomId == resp.room_id) {
          DOM.renderMessages(resp.messages)
        }
      }) 
      .receive( "error", reason => console.log(reason))
    STATE.currentChatroomId = chatroom.roomId 
  };


})

  
export default App
