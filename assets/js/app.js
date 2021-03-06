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
import NProgress from "nprogress"


import WebchatRequests from "./webchat_requests"
import State from "./models/state"
import Hooks from "./events/hooks_events"
import UserEvents from "./events/user_events"
import Controller from "./chat_controller"


if(document.getElementById("chatroom")) {
  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

  // Progress bar
  window.addEventListener("phx:page-loading-start", info => NProgress.start())
  window.addEventListener("phx:page-loading-stop", info => NProgress.done())

  // liveview socket
  let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks.Hooks, params: {_csrf_token: csrfToken}})
  
  WebchatRequests.connect()
  liveSocket.connect()
}
