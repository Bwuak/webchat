defmodule WebchatWeb.Chat.ServerActionComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import WebchatWeb.ErrorHelpers

  def render(assigns) do
    ~L"""
    <%= f = form_for @server_changeset, "#" %>
      <%= if @server_changeset.action do %>
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
