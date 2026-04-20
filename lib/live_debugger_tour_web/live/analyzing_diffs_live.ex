defmodule LiveDebuggerTourWeb.Live.AnalyzingDiffsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 9,
    title: "Analyzing diffs",
    description:
      "Dive into the actual data payloads (diffs) sent over the wire to the browser to understand how Phoenix optimizes UI updates.",
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
        description="Dive into the actual data payloads (diffs) sent over the wire to the browser to understand how Phoenix optimizes UI updates."
      />

      <div class="flex justify-center">
        <span :if={@coming_soon} class="badge badge-warning">coming soon</span>
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end
end
