export const elements = {
  msgContainer: document.getElementById("messages-container"),
  msgInput: document.getElementById("msg-input"),
  sendButton:  document.getElementById("msg-submit"),
  activeServerLink: document.querySelector("a.active-server")
}

export const DOM = {
  getCurrentServerId: () => elements.href.split("=")[1],
  renderNewMessage: (message) => renderNewMessage(message),
  renderMessages: (messages) => renderMessages(messages),
}

var esc = function (str) {
  let div = document.createElement("div")
  div.appendChild(document.createTextNode(str))
  return div.innerHTML
}

var renderMessage = function({id, at, content, user}) {
  const template = document.createElement("div")
  template.classList.add("a-message")
  template.innerHTML = `
  <h4 class="message-username">${esc(user.username)}</h4>
  <p class="message-content">${esc(content)}</p>
  `
  return template
}

var renderNewMessage = function(container, message) {
  const message_div = this.renderMessage(message)
  container.appendChild(message_div)
  container.scrollTop = container.scrollHeight
}
  
var renderOldMessage = function(container, message) {
  const message_div = this.renderMessage(message)
  container.prepend(message_div)
  container.scrollTop = container.scrollHeight
}

var renderMessages = function(container, messages) {
  messages.forEach( message =>
    this.renderOldMessage(container, message)
  )
}
