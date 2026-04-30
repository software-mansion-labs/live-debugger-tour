defmodule LiveDebuggerTourWeb.Live.GlobalCallbackTracesLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 8,
    title: "Global Callback Traces",
    description:
      "Analyze cross-node communication by monitoring messages sent between child LiveComponents and their parent LiveView in real-time."

  alias LiveDebugger.Tour
  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents
  alias LiveDebuggerTourWeb.Live.GlobalCallbackTraces.Receiver
  alias LiveDebuggerTourWeb.Live.GlobalCallbackTraces.Sender

  @tour_steps [
    %{
      id: 1,
      title: "Global Callbacks Navigation",
      description:
        "Look at the <b>Global Traces</b> tab in the debugger's main menu. Think of it as your command center for tracking cross-component communication.",
      target: "#global-traces-navbar-item",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-bars-3"
    },
    %{
      id: 2,
      title: "Global Callbacks Overview",
      description:
        "Unlike standard traces that focus on a single node, <b>Global Traces</b> monitor the entire LiveView process. This allows you to track complex communication loops between the parent LiveView and all its nested LiveComponents simultaneously.",
      target: "#global-traces-section",
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-globe-alt"
    },
    %{
      id: 3,
      title: "Cross-Component Demo",
      description:
        "Let's test it! The dashboard above contains two LiveComponents: a <b>Sender</b> and a <b>Receiver</b>. Click <b>Send Ping</b> on the Sender component. This dispatches an event to the parent LiveView, which then forwards the message to the Receiver. Watch as Global Traces captures this entire communication chain!",
      target: "components-demo-dashboard",
      action: {:client_spotlight, []},
      icon: "hero-server-stack"
    },
    %{
      id: 4,
      title: "Start, Stop & Refresh",
      description:
        "Take control of the data flow. When tracing is <b>Started</b>, you will see live traces stream in as you interact with the app. <b>Stop</b> tracing to freeze the view, allowing you to thoroughly analyze payloads, apply filters, or fetch updates manually.",
      target: "#tracing-tooltip",
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-play-pause"
    },
    %{
      id: 5,
      title: "Component Filtering",
      description:
        "Because Global Traces capture everything, the list can grow rapidly. That is why filters are essential. Once tracing is stopped, open the Filters menu and select <b>ONLY</b> the <code>Receiver</code> component to isolate the exact messages it receives from the parent!",
      target: "#filters-component-tree-collapse",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-funnel"
    },
    %{
      id: 6,
      title: "Search & Highlight",
      description:
        "Looking for a specific payload? The search bar queries trace arguments directly. It automatically expands hidden structs and highlights matching text across all traces. Try searching for \"Sender\" to see it in action.",
      target: "#trace-search-input-search-bar",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-magnifying-glass"
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
        name={@page_title}
        description="Analyze cross-node communication by monitoring messages sent between child LiveComponents and their parent LiveView in real-time."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div class="alert alert-info mb-6">
        <.icon name="hero-information-circle" class="size-5" />
        <div>
          <p class="font-semibold">What are Global Callback Traces?</p>
          <p class="text-sm">
            While standard traces focus on a single selected node, Global Traces monitor the
            entire LiveView process at once. This gives you a bird's-eye view of all events,
            asynchronous tasks, and messages passing between the parent LiveView and all of
            its child LiveComponents simultaneously.
          </p>
        </div>
      </div>

      <div
        id="components-demo-dashboard"
        class="card bg-base-100 shadow-sm mb-6 mt-4 border border-base-300"
      >
        <div class="card-body">
          <h3 class="card-title text-base">
            <.icon name="hero-squares-plus" class="size-5 text-primary" /> LiveComponent Communication
          </h3>
          <p class="text-sm text-base-content/70">
            Sender and Receiver are separate LiveComponents. Clicking "Send Ping" fires an event inside the Sender, sends a message to the parent LiveView, and pushes an update to the Receiver.
          </p>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4">
            <.live_component module={Sender} id="sender" />

            <.live_component module={Receiver} id="receiver" />
          </div>
        </div>
      </div>

      <div id="tour-cards" class="space-y-4 relative z-10">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
          disabled={step.id == 5 and not MapSet.member?(@completed_steps, 4)}
        >
          <:button :if={step.id == 5}>
            <button
              id={"tour-btn-#{step.id}"}
              phx-click={
                Tour.highlight_JS("#filters-component-tree-collapse")
                |> JS.concat(Tour.highlight_JS("[aria-label='Icon panel right']", clear: false))
                |> JS.push("activate_step", value: %{step: step.id})
              }
              class="btn btn-sm btn-soft"
            >
              <.icon name="hero-viewfinder-circle" class="size-4" /> Highlight
            </button>
          </:button>
        </TourComponents.tour_step>
      </div>

      <TourComponents.client_spotlight_hook />
      <TourComponents.clear_spotlight_button :if={@current_step != nil} />

      <div class="flex justify-center gap-3 mt-8">
        <TourComponents.restart_page url={@page_path} />
        <TourComponents.reload_debugger url={RoutesHelper.debugger_node_inspector(self())} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_info({:ping_from_sender, message, timestamp}, socket) do
    send_update(Receiver, id: "receiver", new_message: {message, timestamp})

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}
end
