defmodule WebchatWeb.Chat.ServerCreationComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import WebchatWeb.ErrorHelpers

  alias Webchat.Chat.Participants
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Servers

  
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
          <div>
            <%= label f, "private" %>
            <%= checkbox f, :private %>
          </div>
        </div>
      
        <div>
          <%= submit "Create" %>
        </div>
      </form>
    </div>
    """
  end

  def mount(socket) do
    changeset = Servers.change(%Server{})
    {:ok, assign(socket, changeset: changeset) }
  end

  def handle_event("validate", %{"server" => params}, socket) do
    changeset = 
      socket.assigns.changeset.data
      |> Servers.change(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset) }
  end

  # create the server if it is valid
  def handle_event("save", %{"server" => params}, socket) do
    user = socket.assigns.user
    case Servers.create(user, params) do
      {:ok, new_server} ->
        {:ok, _part} = Participants.create(user, new_server.id)
          

        send(self(), {__MODULE__, :server_created, new_server})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

end
