function idFromHref(link) {
  return link.href.split("=")[1]
}


const DOM = {
  chatroom: document.getElementById("chatroom"),
  msgContainer: document.getElementById("messages-container"),
  msgInput: document.getElementById("msg-input"),
  sendButton:  document.getElementById("msg-submit"),
  userListContainer: document.getElementById("online-users-list"),
  allServers: () => document.querySelectorAll("a.server-link"),

  getCurrentServerId: () => 
    document.getElementById("servers-listing-title").dataset.id, 

  getAllServersId: () => {
    var arr = []
    DOM.allServers().forEach(x => arr.push(idFromHref(x)))
    return arr
  },

  getCurrentChatroomId: () => document.getElementById("chatroom-name").dataset.id,

  renderChatroom: (chatroom) => vm.chatroom = chatroom, 

  clearMessages: () => {
    const node = msgContainer
    while(node.firstChild) {
      node.removeChild(node.lastChild)
    }
  },

}


if(DOM.msgContainer) {
  DOM.msgContainer.innerHTML = 
  `<div id="messages" >
    <div v-for="msg in chatroom.messages" class="a-message">
      <h4 v-if="msg.user" class="message-username">{{ msg.user.username }}</h4>
      <h4 v-else class="no-username">Unknown</h4>
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

export default DOM
