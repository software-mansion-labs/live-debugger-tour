defmodule LiveDebuggerTourWeb.Live.AssignsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 2,
    title: "Assigns",
    description: "Explore LiveView state."

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "Assigns section overview",
      description:
        "This section acts like a live IO.inspect/1 with context. It lets you inspect the current state of assigns for any LiveView or LiveComponent, updating immediately whenever the examined node changes.",
      target: :assigns_section,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-cube"
    },
    %{
      id: 2,
      title: "Assigns change indicator",
      description:
        "Spot bugs faster by seeing exactly what changed. The status dot signals when assigns are updating and stays solid green when they are up to date. Try clicking the Increment button below - the updated counter assign will be immediately highlighted in the debugger.",
      target: "#assigns-title-section",
      has_demo: true,
      action: {:highlight, [dismiss: "click-anywhere", clear: false]},
      icon: "hero-sparkles"
    },
    %{
      id: 3,
      title: "Search Bar",
      description:
        "Large maps and structs are collapsed by default for readability. The search bar automatically finds and expands matching keys. Try searching for the word \"<b>temporary</b>\" to see how it opens up.",
      target: :assigns_search_bar,
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-magnifying-glass"
    },
    %{
      id: 4,
      title: "Pinned assigns",
      description:
        "Focus on what matters most. Pinning keeps specific variables at the top of your view. Try hovering over an assign in the debugger and clicking the pin icon next to it.",
      target: :assigns_pinned,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-map-pin"
    },
    %{
      id: 5,
      title: "Assigns history",
      description:
        "Track state changes over time to see exactly how consecutive actions affected your component. Click the counter a few times, then check the history to see the sequence of mutations step by step.",
      target: :assigns_history_button,
      has_demo: true,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-clock"
    },
    %{
      id: 6,
      title: "Temporary Assigns",
      description:
        "Because temporary assigns are immediately cleared from server memory after rendering, they don't show up in the normal assigns list. This dedicated section catches them so you can still inspect them.",
      target: "#temporary-assigns",
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-archive-box"
    }
  ]
  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :counter, 0)
    socket = assign(socket, :message, ["Happy Debugging"])
    {:ok, tour_page_assigns(socket, @tour_steps), temporary_assigns: [message: []]}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name={@page_title}
        description="Learn how to inspect and monitor your LiveView's state. Open the debugger panel and follow the steps below to see how assigns update in real-time when you interact with the page."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div id="tour-cards" class="space-y-4">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
        >
          <.interactive_demo_section :if={step[:has_demo]} counter={@counter} />
        </TourComponents.tour_step>
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

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end

  attr :counter, :integer, required: true

  defp interactive_demo_section(assigns) do
    ~H"""
    <div class="card shadow-sm mt-4 border border-base-300">
      <div class="card-body p-4">
        <h3 class="card-title text-base">
          <.icon name="hero-beaker" class="size-5 text-primary" /> Interactive Demo
        </h3>
        <p class="text-sm text-base-content/70">
          Use the counter below to change the state and observe how LiveDebugger tracks these mutations in real-time.
        </p>
        <div class="flex items-center gap-4 mt-3">
          <div class="badge badge-lg badge-outline font-mono">
            counter: {@counter}
          </div>
          <button phx-click="increment" class="btn btn-sm btn-soft">
            <.icon name="hero-plus" class="size-4" /> Increment
          </button>
        </div>
      </div>
    </div>
    """
  end
end
