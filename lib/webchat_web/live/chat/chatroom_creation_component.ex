defmodule WebchatWeb.Chat.Models.ChatroomCreationComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import WebchatWeb.ErrorHelpers

  alias Webchat.Chat
  alias Webchat.Chat.Models.Chatroom


  def render(assigns) do
    ~L"""
     <div class="page-container" id="chatroom-creation-<%= @id %>" >
      <%= f = form_for @changeset, "#", [
        phx_target: "#chatroom-creation-#{@id}", 
        phx_submit: "save",
        phx_change: "validate"
      ] %> 
        <h3>Chatroom Creation</h3>
        
        <div>
          <%= label f, "Enter the Chatroom name" %>
          <%= text_input f, :roomname %>
          <%= error_tag f, :roomname %>
        </div>
      
        <div>
          <%= submit "Create" %>
        </div>
      </form>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket} 
  end

  # called after mount, has assigns sent to socket
  def update(assigns, socket) do
    {:ok, assign(socket,
      changeset: Chatroom.changeset(%Chatroom{}, %{}),
      server: assigns.selected_server,
      id: assigns.id
    )}
  end

  def handle_event("validate", %{"chatroom" => params}, socket) do
    changeset = 
      %Chatroom{}
      |> Chatroom.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset) }
  end

  # create the server if it is valid
  def handle_event("save", %{"chatroom" => params}, socket) do
    case socket.assigns.changeset.valid? do
      true ->
        server_id = socket.assigns.server.id
        {:ok, new_chatroom} = Chat.Chatrooms.create_chatroom(server_id, params)
        send(self(), {__MODULE__, :chatroom_created, new_chatroom})
        {:noreply, socket}

      false ->
        changeset = 
          %Chatroom{}
          |> Chatroom.changeset(params) 
          |> Map.put(:action, :insert)
        {:noreply, assign(socket, changeset: changeset) }
    end
  end

end
