import {nullRoom} from "./chatroom"
import Chatroom from "./chatroom"


var State = function() {
  this.channels = {}
  this.chatrooms = {}
  this.currentChatroom = nullRoom
}


State.prototype.getCurrentChatroom = function() {
  return this.currentChatroom
}

State.prototype.getCurrentServerId = function() {
  return this.currentServerId
}

State.prototype.setCurrentServerId = function(id) {
  this.currentServerId = id
}

State.prototype.getCurrentChatroomId = function() {
  return this.getCurrentChatroom().roomId
}

// takes a server id and returns the corresponding channel
State.prototype.getChannelById = function(id) {
  return this.channels[id]
}

State.prototype.getChannel = function() {
  const currentChannelId = this.getCurrentServerId()
  return this.channels[currentChannelId]
}

// creates and store a new channel linked to a server
State.prototype.addNewChannel = function(channel, serverId) {
  this.channels[serverId] = channel
}

// When user unsubscribe to a server
State.prototype.leaveServer = function(serverId) {
  const channel = getChannelById(serverId)
  channel.leave()
  delete this.channels[serverId]
}

State.prototype.createChatroom = function(serverId, chatroomId) {
  chatroomId = Number(chatroomId)
  const newChatroom = new Chatroom(serverId, chatroomId)
  this.chatrooms[chatroomId] = newChatroom

  return newChatroom
}

State.prototype.setCurrentChatroom = function(chatroom) {
  this.currentChatroom = chatroom
}

State.prototype.getChatroom = function(serverId, roomId) {
  if(! (serverId && roomId) ) { 
    return nullRoom 
  }
  else {
    return this.chatrooms[roomId] ? 
      this.chatrooms[roomId] : this.createChatroom(serverId, roomId);
  }
}


let state = new State()
export default state 
