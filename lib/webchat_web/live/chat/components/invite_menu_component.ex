defmodule WebchatWeb.Chat.InviteMenuComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias Webchat.Invitation.Invites

  def render(assigns) do
    ~L"""
    <div class="page-container"> 
      <h3>Manage your invite link:</h3>
      <div id="invite-link-container" >
    <h4 id="invite-link"><%= if @invite do @invite.uuid end %></h4>
      </div>
      <button phx-click="create-link" phx-target="<%= @myself %>" >Create</button>
      <button phx-click="delete-link" phx-target="<%= @myself %>" >Delete</button>
    </div>
    """
  end

  def update(assigns, socket) do
    server = assigns.selected_server
    invite = Invites.get(server)
    {:ok, assign(socket, invite: invite, server: server)} 
  end

  def handle_event("create-link", _params, socket) do
    {:ok, invite} = Invites.create(socket.assigns.server)
    {:noreply, assign(socket, invite: invite)}
  end

  def handle_event("delete-link", _params, socket) do
    Invites.delete(socket.assigns.invite)
    {:noreply, assign(socket, invite: nil)}
  end

end
