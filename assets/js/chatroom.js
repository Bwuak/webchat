let Chatroom = {
  init(socket, element) {
    if(!element) { return }

    socket.connect()
  },
}

export default Chatroom
