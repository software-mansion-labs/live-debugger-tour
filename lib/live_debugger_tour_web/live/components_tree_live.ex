defmodule LiveDebuggerTourWeb.Live.ComponentsTreeLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 5,
    title: "Components Tree",
    description:
      "Visualize complex UI hierarchies with multiple LiveComponents, using the highlight feature to map the tree structure to the browser view.",
    coming_soon: true

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps []

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
        name={@page_title}
        description="Visualize complex UI hierarchies with multiple LiveComponents, using the highlight feature to map the tree structure to the browser view."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div id="tour-cards" class="space-y-4">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
          disabled={step.id != 1 and not MapSet.member?(@completed_steps, 1)}
        />
      </div>

      <TourComponents.client_spotlight_hook />
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
