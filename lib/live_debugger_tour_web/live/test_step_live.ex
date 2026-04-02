defmodule LiveDebuggerTourWeb.Live.TestStepLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Step,
    number: 1,
    title: "Test Step",
    description: "Test step description",
    path: "/steps/test"

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      Test Step
    </div>
    """
  end
end
