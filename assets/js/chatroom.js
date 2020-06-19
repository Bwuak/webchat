import {Presence} from "phoenix"

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

    roomChannel.on("new_message", resp => {
      console.log("got a new message")
      this.renderNewMessage(msgContainer, resp.message)
    })

    roomChannel.join()
      .receive("ok", resp => {
        console.log("joined channel")
        this.renderMessages(msgContainer, resp.messages)
      })
      .receive("error", reason => console.log(reason))
    // let presence = new Presence(roomChannel)

    // presence.onSync(() => {
    //   presence.list((id, {metas: [first, ...rest]}) => {
    //     let count = rest.length + 1
    //     console.log(`${id}: (${count})`)
    //   }).join("")
    // })
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
    <h6 class="message-username">${this.esc(user.username)}</h6>
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
