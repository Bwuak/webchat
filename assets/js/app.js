// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

import socket from "./socket"
import initApplication from "./chat_controller"
import hooksInitializer from "./hooks_events"
import State from "./models/state"
import WebchatRequests from "./webchat_requests"


if(document.getElementById("chatroom")) {
  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

  // initialize app state
  let state = new State()

  // create requets handler
  let webchatRequests = WebchatRequests(state, socket)

  // creating liveview events hooks
  let Hooks = hooksInitializer(state, webchatRequests)

  // liveview socket
  let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks.Hooks, params: {_csrf_token: csrfToken}})
  
  liveSocket.connect()
  socket.connect() // used for channels
  
  initApplication(state, webchatRequests)
}
