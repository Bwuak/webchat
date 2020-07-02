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
  };

  elements.sendButton.addEventListener("click", () => {
    const channelId = STATE.currentServerId
    const roomId = STATE.currentChatroomId
    const payload = {
      content: elements.msgInput.value,
      room_id: roomId 
    }

    console.log("button broken?")
    STATE.channels[channelId].push("new_message", payload)
      .receive("error", e => console.log(e))
    elements.msgInput.value = ""
  });

  // ecoute les changements liveview
  window.addEventListener("phx:page-loading-stop", () => {
    updateServer()
    updateChatroom()
  });


  var joinServer = function(serverId) {
    const channel = socket.channel("server:" + serverId, () => {})
    const presence = new Presence(channel)

    
    channel.join()
      .receive("ok", resp => {
        console.log("Joined server channel")
      })
      .receive("error", reason => console.log(reason))
    
    channel.on("new_message", resp => {
      //STATE.chatrooms[room_id].addMessage()
      DOM.renderNewMessage(resp.message)
    })

    presence.onSync(() => {
      elements.userListContainer.innerHTML = presence.list((id, 
        {user: user, metas: [first, ...rest]}) => {
        return `<p>${user.username}</p>`
      }).join("")
    })

    STATE.channels[serverId] = channel
    STATE.currentServerId = serverId
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
    //if(noChange) { return; }
    DOM.clearMessages()

    joinChatroom(toChatroomId, STATE.currentServerId)
  };

  var joinChatroom = function(roomId, serverId) {
    if( ! roomId ) { return; }
    const payload = {
      room_id: roomId,
    }
    STATE.channels[serverId].push("request_messages", payload)
      .receive( "ok", resp => DOM.renderMessages(resp.messages))
      .receive( "error", reason => console.log(reason))
    STATE.currentChatroomId = roomId 
  };


})

  
export default App
