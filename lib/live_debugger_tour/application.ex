defmodule LiveDebuggerTour.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveDebuggerTourWeb.Telemetry,
      {DNSCluster,
       query: Application.get_env(:live_debugger_tour, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveDebuggerTour.PubSub},
      # Start a worker by calling: LiveDebuggerTour.Worker.start_link(arg)
      # {LiveDebuggerTour.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveDebuggerTourWeb.Endpoint
    ]

    spawn(&open_tour_in_browser/0)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveDebuggerTour.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveDebuggerTourWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp open_tour_in_browser() do
    Process.sleep(500)

    Application.started_applications()
    |> Enum.any?(fn app -> elem(app, 0) == :live_debugger_tour end)
    |> if do
      browser_open(LiveDebuggerTourWeb.Endpoint.static_url())
    else
      open_tour_in_browser()
    end
  end

  defp browser_open(path) do
    start_browser_command =
      case :os.type() do
        {:win32, _} ->
          "start"

        {:unix, :darwin} ->
          "open"

        {:unix, _} ->
          "xdg-open"
      end

    if System.find_executable(start_browser_command) do
      System.cmd(start_browser_command, [path])
    else
      Mix.raise("Command not found: #{start_browser_command}")
    end
  end
end
