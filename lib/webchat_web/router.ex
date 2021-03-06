defmodule WebchatWeb.Router do
  use WebchatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WebchatWeb.Auth
  end

  pipeline :admin do
    plug :authenticate_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/manage", WebchatWeb do
    pipe_through :browser
    pipe_through :admin

    resources "/servers", ServerController
    resources "/room", ChatroomController, only: [:new, :create]
    resources "/users", UserController, only: [:delete, :index]
  end

  scope "/", WebchatWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/invite/:id", InvitationController, :index
    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    live "/chat", ChatLive, layout: {WebchatWeb.LayoutView, :root}
  end

  # Other scopes may use custom stacks.
  # scope "/api", WebchatWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: WebchatWeb.Telemetry
    end
  end
end
