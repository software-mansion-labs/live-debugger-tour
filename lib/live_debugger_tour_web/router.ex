defmodule LiveDebuggerTourWeb.Router do
  use LiveDebuggerTourWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveDebuggerTourWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveDebuggerTourWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/steps/start-debugging", Live.StartDebuggingLive
    live "/steps/test", Live.TestLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveDebuggerTourWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:live_debugger_tour, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LiveDebuggerTourWeb.Telemetry
    end
  end
end
