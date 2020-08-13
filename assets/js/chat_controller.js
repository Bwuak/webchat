import {Presence} from "phoenix"
import regeneratorRuntime from "regenerator-runtime"

import {elements, DOM} from "./views/app_view"
import {Chatroom, nullRoom} from "./models/chatroom.js"


let App = (function(socket, state) {

  socket.connect()
  var scroll = {
    state: "locked"
  }

  setInterval(() => {
    if(scroll.state == "locked"){
      scrolldown()
    }
  }, 50)

  /* hack so user can log out from it's conn session 
  *  Was not able to find conn in liveview socket
  *  Was not able to find a replacement for link in liveview
  */
  const link = document.getElementById("if-anyone-knows-how-to-fix-this-tell-me-please")
  const linkContainer = document.getElementById("link-container")
  linkContainer.appendChild(link)

  function listenToServers() {
    const servers = DOM.getAllServersId()
    servers.forEach( id => createChannel(socket, id))
  }
  listenToServers()

  elements.msgInput.onkeyup = function(e) {
    if(e.keyCode == 13) {
      sendMessage()
    }
  }

  setTimeout(scrolldown, 5)

  function refresh() {
    /* will be changed to liveview hooks */
    const newServerId = updateServer()
    updateChatroom(newServerId)
    sync(state.getCurrentChatroom())
  }

  window.addEventListener("phx:page-loading-stop", () => {
    refresh()
  });


  const div = document.getElementById("messages-container")
  div.addEventListener("scroll", function() {
    if(div.scrollHeight - div.scrollTop == div.clientHeight) {
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

  /* only send if user is in a chatroom */
  function sendMessage() {
    const chatroom_id = DOM.getCurrentChatroomId()
    const msgContent = elements.msgInput.value.trim() 
    if(chatroom_id && msgContent) {
      pushMessage({
        content: msgContent,
        room_id: state.getCurrentChatroomId()
      })
      clearMsgInputField()
    }
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
        const room = getChatroom(serverId, resp.room_id)
        room.addOldMessages(resp.messages)
      }) 
      .receive( "error", reason => console.log(reason))
  }

  function updateServer() {
    const toServerId = DOM.getCurrentServerId()
    const currentServerId = state.getCurrentServerId() 
    if(currentServerId == toServerId ) { return currentServerId; }

    return toServerId
  };


  function createChannel(socket, serverId){
    const channel = socket.channel("server:" + serverId, () => {})
    channel.join()
      .receive("error", reason => console.log(reason))
    channel.on("new_message", resp => {
      state.getChatroom(serverId, resp.message.room_id).addNewMessage(resp.message)
    })

    state.addNewChannel(channel, serverId)
    return channel
  }

  function updateChatroom(serverId) {
    const toChatroomId = DOM.getCurrentChatroomId()
    const noChange = state.getCurrentChatroomId() == toChatroomId
    if(noChange) { return; }
    
    const chatroom = state.getChatroom(serverId, toChatroomId)
    state.setCurrentChatroom(chatroom)
    DOM.renderChatroom(chatroom)
    
  };

  function getChatroom(serverId, roomId) {
    return state.getChatroom(serverId, roomId) 
  };

  function sync(currentRoom) {
    if(currentRoom.getMessagesCount() < 50) {
      requestMessages(currentRoom)
    }
  }

  function requestMessages(chatroom) {
    if(chatroom.roomId == 0) { return; }
    const oldestMsgId = chatroom.oldest != "nil" 
      ? chatroom.oldest : chatroom.newest 

    const payload = {
      room_id: chatroom.roomId,
      oldest: oldestMsgId
    }

    pushRequestMessages(chatroom.serverId, payload)
  };

})


export default App
