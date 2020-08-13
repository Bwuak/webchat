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

/* only send if user is in a chatroom */
    sendMessage: (msgContent) => {
      const room = state.getCurrentChatroom()
      if(msgContent && (room != nullRoom) ) {
        pushMessage({
          content: msgContent,
          room_id: room.roomId
        })
      }
    },


  }

});


export default Requests
