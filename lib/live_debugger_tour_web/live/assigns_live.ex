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
      action: :spotlight,
      dismiss: "click-anywhere",
      # "hero-cube" 
      icon: "hero-code-bracket"
    },
    %{
      id: 2,
      title: "Assigns change indicator",
      description:
        "Spot bugs faster and debug reactivity issues. After triggering event callbacks, changes in the assigns are immediately highlighted so you can confirm they are updating exactly as expected.",
      target: "#assigns-title-section",
      action: :highlight,
      dismiss: "click-anywhere",
      clear: false,
      icon: "hero-sparkles"
    },
    %{
      id: 3,
      title: "Search Bar & Expanding",
      description:
        "Navigate large states easily. If examined assigns are too big, they are collapsed for ease of use. You can use the search bar to find specific keys, expand them, or even copy them to paste directly inside your IEx session.",
      target: :assigns_search_bar,
      action: :highlight,
      dismiss: "click-anywhere",
      icon: "hero-magnifying-glass"
    },
    %{
      id: 4,
      title: "Pinned assigns",
      description:
        "Focus on what matters. Pinning assigns is especially useful when debugging tricky UI state issues, like counters not updating, buttons staying disabled, or incorrect data appearing in forms.",
      target: :assigns_pinned,
      action: :highlight,
      dismiss: "click-target",
      icon: "hero-map-pin"
    },
    %{
      id: 5,
      title: "Assigns history",
      description:
        "Get deeper insight into the LiveView lifecycle. Track state changes over time to clearly see exactly how consecutive user actions and events affected a component's state.",
      target: :assigns_history_button,
      action: :spotlight,
      dismiss: "click-anywhere",
      icon: "hero-clock"
    },
    %{
      id: 6,
      title: "Temporary Assigns",
      description:
        "Catch incorrect or missing updates to your temporary assigns without guesswork. Confirm that your UI state and DOM patching are behaving exactly as intended.",
      target: "#temporary-assigns",
      action: :spotlight,
      dismiss: "click-anywhere",
      icon: "hero-archive-box"
    }
  ]

  #   @tour_steps [
  #   %{
  #     id: 1,
  #     title: "Assigns section overview",
  #     description:
  #       "Callback tracing allows you to monitor function calls in your LiveView app. You can inspect a specific node in the Node Inspector or monitor all nodes via Global Traces.",
  #     target: :assigns_section,
  #     action: :spotlight,
  #     dismiss: "click-anywhere",
  #     icon: "hero-signal"
  #   },
  #   %{
  #     id: 2,
  #     title: "Assigns change indicator",
  #     description:
  #       "In Global Traces, you can search through trace arguments. The tool will automatically expand structs and highlight all occurrences of your searched phrase.",
  #     target: "#assigns-title-section",
  #     action: :highlight,
  #     dismiss: "click-anywhere",
  #     clear: false,
  #     icon: "hero-magnifying-glass"
  #   },
  #   %{
  #     id: 3,
  #     title: "search bar",
  #     description:
  #       "Each trace displays the callback name, an argument preview, timestamp, and execution time. Click a trace to expand it to see detailed arguments, copy them, or open a fullscreen view.",
  #     target: :assigns_search_bar,
  #     action: :highlight,
  #     dismiss: "click-anywhere",
  #     icon: "hero-information-circle"
  #   },
  #   %{
  #     id: 4,
  #     title: "Pinned assigns",
  #     description:
  #       "Tracing has two states: 'Started' for live trace streams (filters disabled), and 'Stopped' to freeze the view, apply filters, and refresh manually.",
  #     target: :assigns_pinned,
  #     action: :highlight,
  #     dismiss: "click-target",
  #     icon: "hero-play-pause"
  #   },
  #   %{
  #     id: 5,
  #     title: "Assigns history",
  #     description:
  #       "When tracing is stopped, use filters to narrow down results. You can filter by specific callbacks (like 'handle_event') or set Execution Time limits to find bottlenecks.",
  #     target: :assigns_history_button,
  #     action: :spotlight,
  #     dismiss: "click-anywhere",
  #     icon: "hero-funnel"
  #   },
  #   %{
  #     id: 6,
  #     title: "Temporary Assigns",
  #     description:
  #       "When tracing is stopped, use filters to narrow down results. You can filter by specific callbacks (like 'handle_event') or set Execution Time limits to find bottlenecks.",
  #     target: "#temporary-assigns",
  #     action: :spotlight,
  #     dismiss: "click-anywhere",
  #     icon: "hero-funnel"
  #   }
  # ]

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
        <TourComponents.restart_page url={@page_path} />
        <TourComponents.reload_debugger url={RoutesHelper.debugger_node_inspector(self())} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end
end
