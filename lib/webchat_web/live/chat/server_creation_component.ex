defmodule WebchatWeb.Chat.ServerCreationComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import WebchatWeb.ErrorHelpers

  alias Webchat.Chat
  alias Webchat.Chat.Server

  def mount(socket) do
    changeset = Server.changeset(%Server{}, %{})
    {:ok, assign(socket, changeset: changeset) }
  end
  
  def render(assigns) do
    ~L"""
    <div class="page-container" id="server-creation-<%= @id %>" >
      <%= f = form_for @changeset, "#", [
        phx_target: "#server-creation-#{@id}", 
        phx_submit: "save",
        phx_change: "validate"
      ] %> 
        <h3>Server Creation</h3>
        
        <div>
          <%= label f, "Enter Server name" %>
          <%= text_input f, :name %>
          <%= error_tag f, :name %>
        </div>
      
        <div>
          <%= submit "Create" %>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("validate", %{"server" => params}, socket) do
    changeset = 
      %Server{}
      |> Server.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset) }
  end

  # create the server if it is valid
  def handle_event("save", %{"server" => params}, socket) do
    case socket.assigns.changeset.valid? do
      true ->
        user = socket.assigns.user
        {:ok, new_server} = Chat.create_server(%{name: params["name"], user_id: user.id})
        send(self(), {__MODULE__, :server_created, new_server})
        {:noreply, socket}

      false ->
        changeset =
          %Server{}
          |> Server.changeset(params)
          |> Map.put(:action, :insert)
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

end
