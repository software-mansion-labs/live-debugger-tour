defmodule LiveDebuggerTourWeb.Live.TestLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 2,
    title: "Test",
    description: "Test",
    path: ~p"/pages/test"

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "Test",
      description: "Test",
      target: :inspect_button,
      action: :spotlight,
      icon: "hero-signal"
    },
    %{
      id: 2,
      title: "Test",
      description: "Test",
      target: "active-live-views",
      action: :spotlight,
      dismiss: "click-anywhere",
      icon: "hero-signal"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, tour_page_assigns(socket, @tour_steps)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name="Test"
        description="Test page for experimentation."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div id="tour-cards" class="space-y-4">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
        />
      </div>

      <TourComponents.clear_spotlight_button :if={@current_step != nil} />

      <div class="flex justify-center gap-3">
        <TourComponents.restart_page url={@page_path} />
        <TourComponents.reload_debugger url={RoutesHelper.debugger_node_inspector(self())} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end
end
