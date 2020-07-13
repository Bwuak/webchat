export const elements = {
  chatroom: document.getElementById("chatroom"),
  msgContainer: document.getElementById("messages-container"),
  msgInput: document.getElementById("msg-input"),
  sendButton:  document.getElementById("msg-submit"),
  userListContainer: document.getElementById("online-users-list"),
  activeServerLink: () => document.querySelector("a.active-server")
}

export const DOM = {
  getCurrentServerId: () => elements.activeServerLink().href.split("=")[1],
  getCurrentChatroomId: () => elements.chatroom.dataset.id,
  renderChatroom: (chatroom) => vm.chatroom = chatroom, 
  clearMessages: () => {
    const node = elements.msgContainer
    while(node.firstChild) {
      node.removeChild(node.lastChild)
    }
  }
}


if(elements.msgContainer){
  elements.msgContainer.innerHTML = 
  `<div id="messages">
    <div v-for="msg in chatroom.messages" class="a-message">
      <h4 v-if="msg.user" class="message-username">{{ msg.user.username }}</h4>
      <h4 v-else class="message-username">Uknown</h4>
      <p class="message-content">{{ msg.content }}</p>
    </div>
  </div>`

  var vm = new Vue({ 
    el: '#messages-container', 
    data: {
      chatroom: {}
    },
  })
}
