defmodule LiveDebuggerTourWeb.Live.ActiveLiveViewsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 11,
    title: "Active LiveViews",
    description:
      "Use the dynamic dashboard to see all currently running LiveView processes across the application as they connect and disconnect.",
    coming_soon: true

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
        description="Use the dynamic dashboard to see all currently running LiveView processes across the application as they connect and disconnect."
      />

      <div class="flex justify-center">
        <span :if={@coming_soon} class="badge badge-warning">coming soon</span>
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end
end
