defmodule WebchatWeb.Chat.RoomCreationComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import WebchatWeb.ErrorHelpers

  alias Webchat.Chat.Chatroom


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
    changeset = Chatroom.changeset(%Chatroom{}, %{})
    {:ok, assign(socket, changeset: changeset) }
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
        user = socket.assigns.user
      false ->
        changeset = 
          %Chatroom{}
          |> Chatroom.changeset(params) 
          |> Map.put(:action, :insert)
        {:noreply, assign(socket, changeset: changeset) }
    end
    # case socket.assigns.changeset.valid? do
    #   true ->
    #     user = socket.assigns.user
    #     {:ok, new_server} = Chat.create_server(%{name: params["name"], user: user})
    #     send(self(), {__MODULE__, :server_created, new_server})
    #     {:noreply, socket}

    #   false ->
    #     changeset =
    #       %Server{}
    #       |> Server.changeset(params)
    #       |> Map.put(:action, :insert)
    #     {:noreply, assign(socket, changeset: changeset)}
    # end
  end

end
