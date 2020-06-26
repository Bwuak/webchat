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
import socket from "./socket"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import Chatroom from "./chatroom"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
liveSocket.connect()
socket.connect()

window.addEventListener("phx:page-loading-start", () => {
  console.log("switching room")
  Chatroom.init(socket, document.getElementById("chatroom"))
})

