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
      
        <%= label f, :name %>
        <%= text_input f, :name %>
        <%= error_tag f, :name %>
      
        <div>
          <%= submit "Save" %>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("validate", _params, socket) do
    changeset = 
      socket.assigns.changeset
      |> Chat.validate_server(socket.assigns.user)

    {:noreply, assign(socket, changeset: changeset) }
  end

  def handle_event("save",_params, socket) do
    IO.puts "save"
    {:noreply, socket}
  end

end
