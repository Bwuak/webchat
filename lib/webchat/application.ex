defmodule Webchat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Webchat.Repo,
      # Start the Telemetry supervisor
      WebchatWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Webchat.PubSub},
      WebchatWeb.Presence,
      # Start the Endpoint (http/https)
      WebchatWeb.Endpoint
      # Start a worker by calling: Webchat.Worker.start_link(arg)
      # {Webchat.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Webchat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WebchatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
