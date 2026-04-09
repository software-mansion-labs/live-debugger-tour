defmodule LiveDebuggerTourWeb.Live.StartDebuggingLive do
  use LiveDebuggerTourWeb, :live_view

  @live_debugger_step 1

  use LiveDebuggerTour.Step,
    number: @live_debugger_step,
    title: "Start Debugging",
    description:
      "Explore the Node Info panel to identify the process PID, module path, and learn how to jump from the debugger to the code editor.",
    path: ~p"/steps/start-debugging"

  alias LiveDebuggerTour.StepDiscovery
  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "PID indicator",
      description:
        "The green dot in the debugger navbar shows your LiveView's PID and confirms the debugger is connected to a live process.",
      target: :navbar_connected,
      action: :spotlight,
      icon: "hero-signal"
    },
    %{
      id: 2,
      title: "Node Info panel",
      description:
        "This panel displays the module name, file path, and node type of the LiveView you are inspecting. It is your starting point for understanding which process the debugger is attached to.",
      target: :node_basic_info,
      action: :spotlight,
      icon: "hero-information-circle"
    },
    %{
      id: 3,
      title: "Open in Editor",
      description:
        "The \"Open in Editor\" button jumps directly to this module's source file in your code editor. Make sure the PLUG_EDITOR environment variable is configured.",
      target: :open_in_editor,
      action: :spotlight,
      icon: "hero-code-bracket"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      self()
      |> RoutesHelper.debugger_node_inspector()
      |> LiveDebugger.Tour.redirect()
    end

    tour_steps = StepDiscovery.list_steps()

    prev_page =
      if @live_debugger_step == 1 do
        ~p"/"
      else
        tour_steps
        |> Enum.at(@live_debugger_step - 2, %{})
        |> Map.get(:path)
      end

    next_page =
      tour_steps
      |> Enum.at(@live_debugger_step, %{})
      |> Map.get(:path)

    {:ok,
     assign(socket,
       page_title: "Start Debugging",
       page_number: @live_debugger_step,
       current_step: nil,
       completed_steps: MapSet.new(),
       tour_steps: @tour_steps,
       prev_page: prev_page,
       next_page: next_page
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name="Start Debugging"
        description="Open the LiveDebugger panel alongside this page and follow the guided steps
          below. Each button will spotlight a part of the debugger UI."
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
        <TourComponents.restart_page />
        <TourComponents.reload_debugger url={RoutesHelper.debugger_node_inspector(self())} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("activate_step", %{"step" => step_id}, socket) do
    {:noreply,
     socket
     |> assign(:current_step, step_id)
     |> update(:completed_steps, &MapSet.put(&1, step_id))}
  end

  def handle_event("clear_tour", _params, socket) do
    {:noreply, assign(socket, :current_step, nil)}
  end
end
