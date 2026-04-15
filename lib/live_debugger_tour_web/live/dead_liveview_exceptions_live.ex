defmodule LiveDebuggerTourWeb.Live.DeadLiveviewExceptionsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 4,
    title: "Dead LiveView & Exceptions",
    description:
      "Trigger a deliberate crash to see how the debugger displays the final state of a dead process and identifies its successor."

  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "Note the current PID",
      description:
        "Open the LiveDebugger and look at the green \"Monitored PID\" badge in the navbar. " <>
          "Remember this PID — after the crash, you'll see it change to a \"Disconnected\" state.",
      target: :navbar_connected,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-signal"
    },
    %{
      id: 2,
      title: "Trigger the crash",
      description:
        "Click the \"Boom!\" button below to raise a RuntimeError. " <>
          "This crashes the LiveView process. Phoenix will automatically restart it with a new PID, " <>
          "but the debugger stays attached to the old (now dead) process.",
      target: "boom-button",
      action: {:client_spotlight, []},
      icon: "hero-fire"
    },
    %{
      id: 3,
      title: "Observe DeadView mode",
      description:
        "The navbar now shows a pink \"Disconnected\" badge instead of the green one. " <>
          "This is DeadView mode — the debugger detected that the process died and is showing its last known state. " <>
          "All assigns and component data are still inspectable.",
      target: :navbar_connected,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-eye"
    },
    %{
      id: 4,
      title: "Inspect the last state",
      description:
        "The Node Info panel still displays the module name and path of the dead process. " <>
          "You can browse its assigns to see exactly what state it held at the moment of the crash.",
      target: :node_basic_info,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-magnifying-glass"
    },
    %{
      id: 5,
      title: "Find the successor",
      description:
        "Click the \"Continue\" button in the disconnected badge area. " <>
          "The debugger will search for the replacement process that Phoenix spawned after the crash " <>
          "and redirect you to inspect it.",
      target: "#navbar-connected + button",
      action: {:spotlight, []},
      icon: "hero-arrow-path"
    }
  ]

  @impl true
  def mount(params, _session, socket) do
    completed = LiveDebuggerTour.Page.parse_completed(params["completed"])

    socket =
      socket
      |> tour_page_assigns(@tour_steps, skip_redirect: true)
      |> assign(counter: 0)

    if not MapSet.member?(completed, 2) do
      self()
      |> LiveDebugger.App.Web.Helpers.Routes.debugger_node_inspector()
      |> LiveDebugger.Tour.redirect()
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name={@page_title}
        description="Crash a LiveView on purpose and see how the debugger preserves its last state in DeadView mode."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div class="card shadow-sm my-6">
        <div class="card-body">
          <h3 class="card-title text-base">
            <.icon name="hero-beaker" class="size-5 text-primary" /> Interactive Demo
          </h3>
          <p class="text-sm text-base-content/70">
            Use the counter to create some state, then crash the process with "Boom!" to see DeadView mode in action.
          </p>
          <div class="flex items-center gap-4 mt-3">
            <div class="badge badge-lg badge-outline font-mono">
              counter: {@counter}
            </div>
            <button id="increment-button" phx-click="increment" class="btn btn-sm btn-soft">
              <.icon name="hero-plus" class="size-4" /> Increment
            </button>
            <button id="boom-button" phx-update="ignore" phx-click="boom" class="btn btn-sm btn-error">
              <.icon name="hero-fire" class="size-4" /> Boom!
            </button>
          </div>
        </div>
      </div>

      <div class="alert alert-info mb-6">
        <.icon name="hero-information-circle" class="size-5" />
        <div>
          <p class="font-semibold">What is DeadView mode?</p>
          <p class="text-sm">
            When a LiveView process crashes, the debugger doesn't lose track of it.
            Instead, it enters DeadView mode — preserving the last known state so you can
            inspect assigns, components, and traces even after the process is gone.
            A "Continue" button helps you find the successor process.
          </p>
        </div>
      </div>

      <div id="tour-cards" class="space-y-4">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
        />
      </div>

      <TourComponents.client_spotlight_hook />
      <TourComponents.clear_spotlight_button :if={@current_step != nil} />

      <div class="flex justify-center gap-3">
        <TourComponents.restart_page url={@page_path} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, counter: socket.assigns.counter + 1)}
  end

  @impl true
  def handle_event("boom", _params, _socket) do
    raise RuntimeError, "Boom! This crash was triggered by the tour to demonstrate DeadView mode."
  end
end
