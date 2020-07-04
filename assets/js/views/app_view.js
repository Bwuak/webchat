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



elements.msgContainer.innerHTML = 
`<div>
  <div v-for="msg in chatroom.messages" class="a-message">
    <h4 class="message-username">{{ esc(msg.user.username) }}</h4>
    <p class="message-content">{{ esc(msg.content) }}</p>
  </div>
</div>`

var vm = new Vue({ 
  el: '#messages-container', 
  data: {
    chatroom: {}
  },

  methods: {
    esc: function (str) {
      let div = document.createElement("div")
      div.appendChild(document.createTextNode(str))
      return div.innerHTML
    }

  }

})

