import {Presence} from "phoenix"

let Chatroom = {
  init(socket, element) {
    if(!element) { return }
    console.log("Chatroom init")

    const roomId = element.getAttribute("data-id")

    this.onReady(roomId, socket)
  },


  onReady(room_id, socket) {
    const roomChannel = socket.channel("room:" + room_id, () => {
    })
    const msgContainer = document.getElementById("messages-container")
    const msgInput = document.getElementById("msg-input")
    const sendButton = document.getElementById("msg-submit")

    window.addEventListener("click", e => {
      msgInput.focus()
    })

    sendButton.addEventListener("click", e => {
      const payload = {content: msgInput.value}
      roomChannel.push("new_message", payload)
        .receive("error", e => console.log(e))
      msgInput.value = ""
    })

    roomChannel.on("new_message", resp => {
      this.renderNewMessage(msgContainer, resp.message)
    })

    roomChannel.join()
      .receive("ok", resp => {
        this.renderMessages(msgContainer, resp.messages)
      })
      .receive("error", reason => console.log(reason))

  },

  esc(str) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderMessage({id, at, content, user}){
    const template = document.createElement("div")
    template.classList.add("a-message")
    template.innerHTML = `
    <h4 class="message-username">${this.esc(user.username)}</h4>
    <p class="message-content">${this.esc(content)}</p>
    `
    return template
  },

  renderNewMessage(container, message) {
    const message_div = this.renderMessage(message)
    container.appendChild(message_div)
    container.scrollTop = container.scrollHeight
  },
  
  renderOldMessage(container, message) {
    const message_div = this.renderMessage(message)
    container.prepend(message_div)
    container.scrollTop = container.scrollHeight
  },

  renderMessages(container, messages) {
    messages.forEach( message =>
      this.renderOldMessage(container, message)
    )
  },

}

export default Chatroom
