defmodule LiveDebuggerTourWeb.Live.ResourcesLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 10,
    title: "Resources",
    description:
      "Monitor real-time performance graphs and watch how specific user interactions cause spikes or changes in system resource usage."

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "Resources Navigation",
      description:
        "You can always return to this view using the Resources tab in the debugger's main menu. This is where you will find the performance analysis of your process.",
      target: "#resources-navbar-item",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-bars-3"
    },
    %{
      id: 2,
      title: "Process Information",
      description:
        "This section displays raw Erlang VM metrics for the current LiveView process. It tracks everything from memory consumption to reductions (CPU work) and the message queue length.",
      target: "#process-info",
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-server"
    },
    %{
      id: 3,
      title: "Refresh Interval",
      description:
        "To see spikes clearly, <b>change the Refresh Rate to 1 second</b>. This makes the graph update much faster, allowing us to catch short-lived resource changes during the tutorial.",
      target: "button[aria-label='Refresh Rate']",
      action: {:highlight, [dismiss: "click-anywhere", clear: false]},
      icon: "hero-clock"
    },
    %{
      id: 4,
      title: "Metrics & Legend",
      description:
        "The chart tracks: <b>Memory</b> (total), <b>Heap/Stack</b> (data memory), <b>Reductions</b> (CPU work), and <b>Message Queue</b>. <br><br> Click the labels in the chart legend to show or hide specific data series.",
      target: "#process-info-chart-wrapper",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-list-bullet"
    },
    %{
      id: 5,
      title: "Interactive Demos",
      description:
        "Time to see it in action! Use the panel below to simulate different types of load on the LiveView process. Watch the chart to see how the system reacts in real-time.",
      target: "#process-info-chart-wrapper",
      has_demo: true,
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-beaker"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      self()
      |> RoutesHelper.debugger_node_inspector()
      |> LiveDebugger.Tour.redirect()
    end

    socket =
      socket
      |> assign(:heavy_payload, nil)
      |> tour_page_assigns(@tour_steps)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name={@page_title}
        description="Monitor real-time performance graphs and watch how specific user interactions cause spikes or changes in system resource usage."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div id="tour-cards" class="space-y-4 relative z-10">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
        >
          <.resources_demo_panel :if={Map.get(step, :has_demo)} />
        </TourComponents.tour_step>
      </div>

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
  def handle_event("spike_memory", _params, socket) do
    huge_binary = :crypto.strong_rand_bytes(30_000_000)

    Process.send_after(self(), :clear_memory, 4000)

    {:noreply, assign(socket, :heavy_payload, huge_binary)}
  end

  @impl true
  def handle_event("spike_heap", _params, socket) do
    huge_list = Enum.to_list(1..1_000_000)
    Process.send_after(self(), :clear_memory, 4000)

    {:noreply, assign(socket, :heavy_payload, huge_list)}
  end

  @impl true
  def handle_event("spike_stack", _params, socket) do
    blow_stack(20_000)
    {:noreply, socket}
  end

  @impl true
  def handle_event("spike_cpu", _params, socket) do
    Enum.reduce(1..2_000_000, 0, fn x, acc -> acc + :erlang.phash2(x) end)
    {:noreply, socket}
  end

  @impl true
  def handle_event("spike_msg_queue", _params, socket) do
    Enum.each(1..50_000, fn _ -> send(self(), :ignored_message) end)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:clear_memory, socket) do
    socket = assign(socket, :heavy_payload, nil)
    :erlang.garbage_collect(self())
    {:noreply, socket}
  end

  @impl true
  def handle_info(:ignored_message, socket), do: {:noreply, socket}

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  defp blow_stack(0), do: Process.sleep(1500)

  defp blow_stack(n) do
    _res = blow_stack(n - 1)
    :ok
  end

  defp resources_demo_panel(assigns) do
    ~H"""
    <div id="resources-demo-panel" class="card shadow-sm mt-4 border border-base-300">
      <div class="card-body p-4">
        <h3 class="card-title text-base mb-4">
          <.icon name="hero-play" class="size-5 text-primary" /> Trigger Resource Spikes
        </h3>

        <div class="flex flex-wrap gap-3">
          <button phx-click="spike_memory" class="btn btn-sm btn-primary">
            <.icon name="hero-circle-stack" class="size-4" /> Total Memory
          </button>

          <button phx-click="spike_heap" class="btn btn-sm btn-info">
            <.icon name="hero-queue-list" class="size-4" /> Heap Size
          </button>

          <button phx-click="spike_stack" class="btn btn-sm btn-warning">
            <.icon name="hero-bars-arrow-up" class="size-4" /> Stack Size
          </button>

          <button phx-click="spike_cpu" class="btn btn-sm btn-secondary">
            <.icon name="hero-cpu-chip" class="size-4" /> CPU (Reductions)
          </button>

          <button phx-click="spike_msg_queue" class="btn btn-sm btn-accent">
            <.icon name="hero-envelope" class="size-4" /> Message Queue
          </button>
        </div>

        <p class="text-xs text-base-content/60 mt-4">
          * Note: Metrics require their legend marker to be enabled to be visible.
        </p>
      </div>
    </div>
    """
  end
end
