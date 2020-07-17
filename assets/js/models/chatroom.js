var Chatroom = function(serverId, roomId) {
  this.roomId = roomId;
  this.serverId = serverId;
  this.messages = [];
  this.newest = "nil"
  this.oldest = "nil"
}

Chatroom.prototype.addNewMessage = function(msg) {
  this.newest = msg.id
  this.messages.push(msg)
}

Chatroom.prototype.addOldMessages = function(msgs) {
  if(msgs.length > 0) { 
    this.oldest = msgs[0].id
    this.messages = msgs.concat(this.messages)
  }
}

Chatroom.prototype.getMessages = function() { 
  return this.messages
}

Chatroom.prototype.getMessagesCount = function() {
  return this.messages.length
}

export default Chatroom
export const nullRoom = {
  chatroom: {
    roomId: 'none',
    messages: []
  }
}
