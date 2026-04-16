defmodule LiveDebuggerTourWeb.Live.CallbackTracesLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 3,
    title: "Callback Traces",
    description:
      "Monitor function calls in real-time. Learn how to freeze traces, apply filters, and pinpoint performance bottlenecks in your LiveView lifecycle."

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "Callback Traces Overview",
      description:
        "This feature allows you to see exactly how lifecycle functions are being called. Try clicking the Increment button in the demo below and watch as a new \"handle_event\" trace instantly appears in the debugger.",
      target: :callback_traces_section,
      demo: %{
        event: "increment",
        label: "Increment",
        is_slow: false,
        description:
          "Click the button below to trigger a <code>handle_event</code> callback and see it immediately appear in the debugger's traces list."
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-queue-list"
    },
    %{
      id: 2,
      title: "Trace Information",
      description:
        "Analyze the details. Each trace displays the callback arity, argument preview, and execution time. Try clicking the \"Slow Increment\" button below to simulate a heavy operation, and observe how the trace execution time is highlighted in red.",
      target: :callback_traces_first_trace,
      demo: %{
        event: "slow_increment",
        label: "Slow Increment",
        is_slow: true,
        description:
          "Clicking the button below will deliberately pause the process for over 1 second. Watch how the tracer highlights the execution time to help you spot bottlenecks."
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-document-magnifying-glass"
    },
    %{
      id: 3,
      title: "Start, Stop and Refresh",
      description:
        "Control the flow of traces. Started streams traces live as you interact with the app. Try stopping it - this freezes the view, allowing you to apply filters and manually load the newest traces.",
      target: :callback_traces_toggle_tracing,
      action: {:spotlight, [dismiss: "click-target"]},
      icon: "hero-play-pause"
    },
    %{
      id: 4,
      title: "Filtering Traces",
      description:
        "Find exactly what you need. Once tracing is stopped, use filters to isolate specific callbacks. You can also set Execution Time limits to easily spot performance bottlenecks.",
      target: :callback_traces_filters_button,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-funnel"
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

    {:ok,
     socket
     |> assign(counter: 0)
     |> tour_page_assigns(@tour_steps)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name={@page_title}
        description="Discover how to track your LiveView's lifecycle events. Open the debugger panel and follow the steps below to monitor callbacks in real-time, pause the stream, apply filters, and inspect massive payloads."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div id="tour-cards" class="space-y-4">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
          disabled={step.id == 3 and not MapSet.member?(@completed_steps, 2)}
        >
          <.interactive_demo_section :if={step[:demo]} demo={step.demo} counter={@counter} />
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

  @impl true
  def handle_event("slow_increment", _params, socket) do
    Process.sleep(1200)
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end

  attr :counter, :integer, required: true
  attr :demo, :map, required: true

  defp interactive_demo_section(assigns) do
    ~H"""
    <div class="card shadow-sm mt-4 border border-base-300">
      <div class="card-body p-4">
        <h3 class="card-title text-base">
          <.icon
            name={if @demo.is_slow, do: "hero-clock", else: "hero-beaker"}
            class="size-5 text-primary"
          />
          {if @demo.is_slow, do: "Slow Execution Demo", else: "Interactive Demo"}
        </h3>

        <p class="text-sm text-base-content/70">
          {Phoenix.HTML.raw(@demo.description)}
        </p>

        <div class="flex items-center gap-4 mt-3">
          <div class="badge badge-lg badge-outline font-mono">
            counter: {@counter}
          </div>
          <button
            phx-click={@demo.event}
            phx-disable-with={if @demo.is_slow, do: "Processing...", else: nil}
            class="btn btn-sm btn-soft"
          >
            <.icon name={if @demo.is_slow, do: "hero-play", else: "hero-plus"} class="size-4" />
            {@demo.label}
          </button>
        </div>
      </div>
    </div>
    """
  end
end
