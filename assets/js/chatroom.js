let Chatroom = {
  init(socket, element) {
    if(!element) { return }

    const roomId = element.getAttribute("data-id")
    socket.connect()

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

    roomChannel.join()
      .receive("ok", resp => {
        console.log(resp)
        this.renderMessages(msgContainer, resp.messages)
      })

    roomChannel.on("new_message", resp => {
      this.renderMessage(msgContainer, resp, resp.message)
    })


  },

  esc(str) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderMessage(container, {id, at, content, user}) {
    const template = document.createElement("div")
    template.classList.add("a-message")
    console.log(template)
    template.innerHTML = `
    <h6 class="message-username">${this.esc(user.username)}</h6>
    <p class="message-content">${this.esc(content)}</p>
    `
    container.appendChild(template)
    container.scrollTop = container.scrollHeight
  },

  renderMessages(container, messages) {
    console.log(messages)
    messages.forEach( message =>
      this.renderMessage(container, message)
    )
  },

}

export default Chatroom
