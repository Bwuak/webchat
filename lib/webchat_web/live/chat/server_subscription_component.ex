defmodule WebchatWeb.Chat.ServerSubscriptionComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import WebchatWeb.ErrorHelpers

  alias Webchat.Participations
  alias Webchat.Participations.Role
  alias Webchat.Chat.Server

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

  # Handle server id form, 
  # Create a participation if possible 
  # Redirect user
  def handle_event("save", %{"server_id" => server_id}, socket) do
    message = 
      case fetch_server(Integer.parse(server_id) ) do
        :error ->
          {__MODULE__, :error, "invalid server id input"}

        :not_found ->
          {__MODULE__, :error, "server not found"}

        server = %Server{} ->
          user = socket.assigns.user
          {:ok, _} = Participations.create_participation(
            user, Webchat.Repo.get!(Role, 1), server )

          {__MODULE__, :server_joined, server}
      end

    send(self(), message)
    {:noreply, socket}
  end

  defp fetch_server({server_id, _}) when is_integer(server_id) do
    case Webchat.Repo.get(Server, server_id) do
      server = %Server{} ->
        server
      _ -> 
        :not_found
    end
  end

  defp fetch_server(_), do: :error


end
