defmodule WebchatWeb.Chat.ServerSubscriptionComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias WebchatWeb.Chat.ServerAuth

  def render(assigns) do
    ~L"""
    <div class="page-container" id="server-sub-<%= @id %>" >
      <form phx-submit="save" phx-target=<%= "#server-sub-#{ @id }" %> >
        <h3>Join a Server</h3>
        
        <div>
          <label label_for="server_id" >Server's ID:</label>
          <input type="text" id="server_id" name="server_id" ></input>
        </div>
      
        <div>
          <%= submit "Join" %>
        </div>
      </form>
     </div>
    """
  end

  def handle_event("save", %{"server_id" => server_id}, socket) do
      case Integer.parse(server_id) do
        :error ->
          send(self(), {__MODULE__, :error, "invalid server id input"})

        {server_id, _} ->
          if ServerAuth.try_join(server_id, socket.assigns.user) do
            send(self(), {__MODULE__, :server_joined, server_id})
          else
            nil
          end
      end

    {:noreply, socket}
  end

end
