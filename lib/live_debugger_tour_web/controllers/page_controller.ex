defmodule LiveDebuggerTourWeb.PageController do
  use LiveDebuggerTourWeb, :controller

  def home(conn, _params) do
    steps = LiveDebuggerTour.StepDiscovery.list_steps()
    render(conn, :home, steps: steps)
  end
end
