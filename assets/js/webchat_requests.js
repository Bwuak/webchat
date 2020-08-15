import socket from "./socket"
import {nullRoom} from "./models/chatroom"
import State from "./models/state"


let Requests = (function() {


  function pushMessage(payload) { 
    const channel = State.getChannel()
    channel.push("new_message", payload)
      .receive("error", e => console.log(e))
  }

  function pushRequestMessages(serverId, payload) {
    const channel = State.getChannelById(serverId)
    channel.push("request_messages", payload)
      .receive( "ok", resp => {
        const room = State.getChatroom(serverId, resp.room_id)
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
      const room = State.getCurrentChatroom()
      if(msgContent && (room != nullRoom) ) {
        pushMessage({
          content: msgContent,
          room_id: room.roomId
        })
      }
    },

    joinServer: (serverId) => {
      // Join a server channel
      if( serverId && (! State.getChannelById(serverId)) ) {
        const channel = socket.channel("server:" + serverId, () => {})
        channel.join()
          .receive("error", reason => console.log(reason) )

        channel.on("new_message", resp => {
          State.getChatroom(serverId, resp.message.room_id)
            .addNewMessage(resp.message)
        })
        State.addNewChannel(channel, serverId)
      }
      State.setCurrentServerId(serverId)
    },

    connect: () => {
      socket.connect()
    }

  }

})()


export default Requests
