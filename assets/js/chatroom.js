let Chatroom = {
  init(socket, element) {
    console.log("WTF")
    if(!element) { return }
    console.log("wtf")

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


    sendButton.addEventListener("click", e => {
      const payload = {content: msgInput.value}
      roomChannel.push("new_message", payload)
        .receive("error", e => console.log(e))
      msgInput.value = ""
    })

    roomChannel.join()
      .receive("ok", resp => {
        console.log(resp)
      })

    roomChannel.on("new_message", resp => {
      this.renderMessage(msgContainer, resp)
    })

  },

  esc(str) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderMessage(container, {id, at, content, user}) {
    const template = document.createElement("div")
    template.innerHTML = `
    <p>${this.esc(user)}</p>
    `
    container.appendChild(template)
    container.scrollTop = container.scrollHeight
  },

  renderMessages(messages, container) {
    messages.foEach( message =>
      renderMessage(container, message)
    )
  },

}

export default Chatroom
