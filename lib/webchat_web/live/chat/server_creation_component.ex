defmodule WebchatWeb.Chat.ServerCreationComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import WebchatWeb.ErrorHelpers

  alias Webchat.Chat.Server

  def mount(socket) do
    changeset = Server.changeset(%Server{}, %{})
    {:ok, assign(socket, :changeset, changeset) }
  end
  
  def render(assigns) do
    ~L"""
    <%= f = form_for @changeset, "#" %>
      <%= if @changeset.action do %>
        <div class="alert alert-danger">
          <p>Oops, something went wrong! Please check the errors below.</p>
        </div>
      <% end %>
    
      <%= label f, :name %>
      <%= text_input f, :name %>
      <%= error_tag f, :name %>
    
      <div>
        <%= submit "Save" %>
      </div>
    </form>
    """
  end

end
