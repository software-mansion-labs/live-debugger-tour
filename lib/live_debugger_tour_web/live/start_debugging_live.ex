defmodule LiveDebuggerTourWeb.Live.StartDebuggingLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 1,
    title: "Start Debugging",
    description:
      "Explore the Node Info panel to identify the process PID, module path, and learn how to jump from the debugger to the code editor."

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "Open LiveDebugger",
      description:
        "Look for the floating bug icon button in the bottom-right corner of this page. Click it to open the LiveDebugger panel in a new tab. This button is injected automatically when LiveDebugger is added as a dependency.",
      target: "live-debugger-debug-button",
      action: {:client_spotlight, []},
      icon: "hero-bug-ant"
    },
    %{
      id: 2,
      title: "PID indicator",
      description:
        "The green dot in the debugger navbar shows your LiveView's PID and confirms the debugger is connected to a live process.",
      target: :navbar_connected,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-signal"
    },
    %{
      id: 3,
      title: "Node Info panel",
      description:
        "This panel displays the module name, file path, and node type of the LiveView you are inspecting. It is your starting point for understanding which process the debugger is attached to.",
      target: :node_basic_info,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-information-circle"
    },
    %{
      id: 4,
      title: "Open in Editor",
      description:
        "The \"Open in Editor\" button jumps directly to this module's source file in your code editor. " <>
          "LiveDebugger checks ELIXIR_EDITOR, then TERM_PROGRAM (set automatically by VS Code/Zed terminals), then EDITOR. " <>
          "For VS Code, add to your shell profile:",
      code_snippet: "export ELIXIR_EDITOR=\"code --goto\"",
      target: :open_in_editor,
      action: {:spotlight, []},
      icon: "hero-code-bracket"
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
        description="Follow the guided steps below to explore the key parts of the LiveDebugger interface."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

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
        <TourComponents.reload_debugger url={RoutesHelper.debugger_node_inspector(self())} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end
end
