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
        "This feature allows you to see exactly how lifecycle functions are being called in your application. You can monitor a specific node here in the Node Inspector, or track all nodes at once using Global Traces.",
      target: :callback_traces_section,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-queue-list"
    },
    %{
      id: 2,
      title: "Start, Stop and Refresh",
      description:
        "Control the flow of traces. Started streams traces live as you interact with the app. Try stopping it - this freezes the view, allowing you to apply filters and manually load the newest traces.",
      target: :callback_traces_toggle_tracing,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-play-pause"
    },
    %{
      id: 3,
      title: "Filtering Traces",
      description:
        "Find exactly what you need. Once tracing is stopped, use filters to isolate specific callbacks. You can also set Execution Time limits to easily spot performance bottlenecks.",
      target: :callback_traces_filters_button,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-funnel"
    },
    %{
      id: 4,
      title: "Trace Information",
      description:
        "Analyze the details. Each trace displays the callback arity, argument preview, and execution time. Try clicking a trace to expand it, copy the arguments, open in edior or view them in fullscreen.",
      target: :callback_traces_first_trace,
      action: {:spotlight, [dismiss: "click-target"]},
      icon: "hero-document-magnifying-glass"
    },
    %{
      id: 5,
      title: "Search & Highlight",
      description:
        "The search bar lets you query arguments directly. It automatically expands hidden structs and highlights every matching phrase, making it easy to navigate massive payloads.",
      target: :callback_traces_search_bar,
      action: {:highlight, [dismiss: "click-anywhere"]},
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
