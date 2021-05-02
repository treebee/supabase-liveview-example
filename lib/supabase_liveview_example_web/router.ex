defmodule SupabaseLiveviewExampleWeb.Router do
  use SupabaseLiveviewExampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SupabaseLiveviewExampleWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/", SupabaseLiveviewExampleWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/debug", DebugLive, :index

    get "/login", LoginController, :index
    post "/login", LoginController, :login
    get "/logout", LoginController, :logout
  end

  # Other scopes may use custom stacks.
  scope "/api", SupabaseLiveviewExampleWeb do
    pipe_through :api

    post "/session", LoginController, :session
  end

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
      live_dashboard "/dashboard", metrics: SupabaseLiveviewExampleWeb.Telemetry
    end
  end
end
