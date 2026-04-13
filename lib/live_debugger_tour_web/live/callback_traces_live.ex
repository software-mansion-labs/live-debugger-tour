defmodule LiveDebuggerTourWeb.Live.CallbackTracesLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 3,
    title: "Callback Traces",
    description: "Explore LiveView lifecycle with recorded traces."

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "Callback Traces Overview",
      description:
        "Callback tracing allows you to monitor function calls in your LiveView app. You can inspect a specific node in the Node Inspector or monitor all nodes via Global Traces.",
      target: :callback_traces_section,
      action: :spotlight,
      dismiss: "click-anywhere",
      icon: "hero-signal"
    },
    %{
      id: 2,
      title: "Exploring a Single Trace",
      description:
        "Each trace displays the callback name, an argument preview, timestamp, and execution time. Click a trace to expand it to see detailed arguments, copy them, or open a fullscreen view.",
      target: :callback_traces_first_trace,
      action: :spotlight,
      dismiss: "click-target",
      icon: "hero-information-circle"
    },
    %{
      id: 3,
      title: "Start and Stop Tracing",
      description:
        "Tracing has two states: 'Started' for live trace streams (filters disabled), and 'Stopped' to freeze the view, apply filters, and refresh manually.",
      target: :callback_traces_toggle_tracing,
      action: :spotlight,
      dismiss: "click-target",
      icon: "hero-play-pause"
    },
    %{
      id: 4,
      title: "Filtering Traces",
      description:
        "When tracing is stopped, use filters to narrow down results. You can filter by specific callbacks (like 'handle_event') or set Execution Time limits to find bottlenecks.",
      target: :callback_traces_filters_button,
      action: :spotlight,
      dismiss: "click-anywhere",
      icon: "hero-funnel"
    },
    %{
      id: 5,
      title: "Searching Inside Traces",
      description:
        "In Global Traces, you can search through trace arguments. The tool will automatically expand structs and highlight all occurrences of your searched phrase.",
      target: :callback_traces_search_bar,
      action: :spotlight,
      dismiss: "click-anywhere",
      icon: "hero-magnifying-glass"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      self()
      |> RoutesHelper.debugger_node_inspector()
      |> LiveDebugger.Tour.redirect()
    end

    {:ok, tour_page_assigns(socket, @tour_steps)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name="Callback Traces"
        description="Learn how to monitor function calls, inspect arguments, and find performance bottlenecks in your LiveView app. Open the LiveDebugger panel and follow the steps below."
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
        <TourComponents.restart_page url={@page_path} />
        <TourComponents.reload_debugger url={RoutesHelper.debugger_node_inspector(self())} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end
end
