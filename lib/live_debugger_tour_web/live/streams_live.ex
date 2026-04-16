defmodule LiveDebuggerTourWeb.Live.StreamsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 7,
    title: "Streams",
    description:
      "Examine how Phoenix Streams are handled by the debugger, showing how large collections are efficiently managed and updated.",
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
        description="Examine how Phoenix Streams are handled by the debugger, showing how large collections are efficiently managed and updated."
      />

      <div class="flex justify-center">
        <span :if={@coming_soon} class="badge badge-warning">coming soon</span>
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end
end
