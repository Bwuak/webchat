import {nullRoom} from "./models/chatroom"


let Requests = (function(state) {

  function pushMessage(payload) { 
    const channel = state.getChannel()
    channel.push("new_message", payload)
      .receive("error", e => console.log(e))
  }

  function pushRequestMessages(serverId, payload) {
    const channel = state.getChannelById(serverId)
    channel.push("request_messages", payload)
      .receive( "ok", resp => {
        const room = state.getChatroom(serverId, resp.room_id)
        room.addOldMessages(resp.messages)
      }) 
      .receive( "error", reason => console.log(reason))
  }


  return {

    requestMessages: (chatroom) => {
      if(chatroom == nullRoom) { return; }
      const oldestMsgId = chatroom.oldest != "nil" 
        ? chatroom.oldest : chatroom.newest 
  
      const payload = {
        room_id: chatroom.roomId,
        oldest: oldestMsgId
      }
  
      pushRequestMessages(chatroom.serverId, payload)
    },

    sendMessage: (msgContent) => {
      const room = state.getCurrentChatroom()
      if(msgContent && (room != nullRoom) ) {
        pushMessage({
          content: msgContent,
          room_id: room.roomId
        })
      }
    },

    joinServerChannel: (socket, serverId) => {
      const channel = socket.channel("server:" + serverId, () => {})
      channel.join()
        .receive("error", reason => console.log(reason) )

      channel.on("new_message", resp => {
        state.getChatroom(serverId, resp.message.room_id)
          .addNewMessage(resp.message)
      })

      state.addNewChannel(channel, serverId)
      return channel
    },

    leaveServerChannel: (serverId) => {
      state.leaveServer(serverId)
    }



  }

});


export default Requests
