// Fetch messages from state
//   -> < 50 fetch messages from server
// add received messages to state
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
// - adding messages to state
// - has one active chatroom in state
// - has one active server in state?
import {Presence} from "phoenix"

import socket from "./socket"
import {elements, DOM} from "./views/app_view"
import Chatroom from "./models/chatroom.js"

let App = (function() {

  socket.connect()
  const state = {
    channels: {},
    chatrooms: {},
  };

  elements.sendButton.addEventListener("click", () => {
    const channelId = state.currentServerId
    const roomId = state.currentChatroomId
    const payload = {
      content: elements.msgInput.value,
      room_id: roomId 
    }

    console.log("button broken?")
    state.channels[channelId].push("new_message", payload)
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
      //state.chatrooms[room_id].addMessage()
      DOM.renderNewMessage(resp.message)
    })

    presence.onSync(() => {
      elements.userListContainer.innerHTML = presence.list((id, 
        {user: user, metas: [first, ...rest]}) => {
          return `<p>${user.username}</p>`
        }).join("")
    })

    state.channels[serverId] = channel
    state.currentServerId = serverId
  };

  var leaveServer = function(serverId) {
    if( ! state.channels[serverId] ) { return; }
    state.channels[serverId].leave()
    delete state.channels[serverId]
  };

  var updateServer = function() {
    const toServerId = DOM.getCurrentServerId()
    if(state.currentServerId == toServerId ) { return; }

    leaveServer(state.currentServerId)
    joinServer(toServerId)
  };

  var updateChatroom = function() {
    const toChatroomId = DOM.getCurrentChatroomId()
    const noChange = state.currentChatroomId == toChatroomId
    //if(noChange) { return; }
    DOM.clearMessages()

    joinChatroom(toChatroomId, state.currentServerId)
  };

  var joinChatroom = function(roomId, serverId) {
    if( ! roomId ) { return; }
    const payload = {
      room_id: roomId,
    }
    state.channels[serverId].push("request_messages", payload)
      .receive( "ok", resp => DOM.renderMessages(resp.messages))
      .receive( "error", reason => console.log(reason))
    state.currentChatroomId = roomId 
  };


})

  
export default App
