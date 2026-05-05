defmodule LiveDebuggerTourWeb.Live.AnalyzingDiffsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 9,
    title: "Analyzing diffs",
    description:
      "Dive into the actual data payloads (diffs) sent over the wire to the browser to understand how Phoenix optimizes UI updates."

  alias LiveDebugger.Tour
  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @messages ["Hello", "Bonjour", "Cześć"]

  @tour_steps [
    %{
      id: 1,
      title: "Diffs live in Global Callbacks",
      description:
        "Diffs are recorded at the LiveView process level, not per node, so they only show up in the <b>Global Callbacks</b> tab. The debugger has been opened on that view for you.",
      target: "#global-traces-navbar-item",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-bars-3"
    },
    %{
      id: 2,
      title: "Pause tracing",
      description:
        "Filters can only be edited when tracing is paused. Click the <b>Stop</b> button to freeze the live trace stream so we can configure what to capture.",
      target: :callback_traces_toggle_tracing,
      action: {:spotlight, [dismiss: "click-target"]},
      icon: "hero-pause"
    },
    %{
      id: 3,
      title: "Enable diff tracing",
      description:
        "Diff traces are hidden by default. With tracing paused, open the <b>Filters</b> sidebar, scroll to <b>Other filters</b>, toggle <b>“Show LiveView diffs sent to browser”</b>, and click <b>Apply</b>.",
      target: "div:has(> div > div > input#filters-sidebar-form_trace_diffs)",
      action: {:highlight, [dismiss: "click-target"]},
      icon: "hero-funnel"
    },
    %{
      id: 4,
      title: "Resume tracing",
      description:
        "With the diff filter saved, click <b>Start</b> to resume capturing. Diffs will now stream into the panel alongside callback traces as you interact with the demo above.",
      target: :callback_traces_toggle_tracing,
      action: {:spotlight, [dismiss: "click-target"]},
      icon: "hero-play"
    },
    %{
      id: 5,
      title: "Send your first diff",
      description:
        "Click <b>Tick counter</b> in the demo above. A new <b>“Diff sent”</b> entry appears at the top of the trace list with a tiny byte-size badge &ndash; Phoenix only shipped the integer that changed.",
      target: "tick-counter",
      action: {:client_spotlight, []},
      icon: "hero-paper-airplane",
      demo: %{event: "tick_counter"}
    },
    %{
      id: 6,
      title: "Inspect the wire payload",
      description:
        "Click the diff trace to expand it. The <b>Diff content</b> body is the literal JSON Phoenix wrote to the WebSocket &ndash; a sparse map keyed by component IDs, carrying <i>only</i> the fields that changed. Everything else is reused from the previous render.",
      target: "#global-traces-stream > :first-child",
      secondary_target:
        "#global-traces-stream > :first-child > summary > div > :last-child > :last-child > span",
      action: {:spotlight, [dismiss: "click-target"]},
      icon: "hero-magnifying-glass"
    },
    %{
      id: 7,
      title: "Different changes, different diffs",
      description:
        "Trigger each demo button in turn: <b>Cycle message</b> (text update), <b>Add item</b> (collection update), and <b>Update everything</b> (multi-key update). Compare the size badges &ndash; bigger UI changes ship bigger diffs, but Phoenix never re-sends what didn't move.",
      target: "wire-payload-demo",
      action: {:client_spotlight, []},
      icon: "hero-scale"
    },
    %{
      id: 8,
      title: "Search inside payloads",
      description:
        "The search bar matches text inside diff bodies, not just callback args. Try searching for text values you see in the demo to find every diff that touched it &ndash; matches highlight inside each expanded body.",
      target: :callback_traces_search_bar,
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-magnifying-glass-circle"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(counter: 0, message: "Hello", items: [])
     |> tour_page_assigns(@tour_steps,
       redirect_url: RoutesHelper.debugger_global_traces(self())
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name={@page_title}
        description="Dive into the actual data payloads (diffs) sent over the wire to the browser to understand how Phoenix optimizes UI updates."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div class="alert alert-info mb-6">
        <.icon name="hero-information-circle" class="size-5" />
        <div>
          <p class="font-semibold">What is a LiveView diff?</p>
          <p class="text-sm">
            On every state change, Phoenix renders a sparse JSON map containing only the parts
            of the template that actually changed and ships it over the WebSocket. The browser
            merges it into the previous render &ndash; no full HTML re-paint, no over-the-wire bloat.
            That's why LiveView feels instant on slow networks.
          </p>
        </div>
      </div>

      <.wire_payload_demo counter={@counter} message={@message} items={@items} />

      <div id="tour-cards" class="space-y-4 relative z-10">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
          disabled={step_disabled?(step.id, @completed_steps)}
        >
          <:button :if={step.id == 3}>
            <button
              id={"tour-btn-#{step.id}"}
              disabled={step_disabled?(step.id, @completed_steps)}
              phx-click={
                Tour.highlight_JS(step.target)
                |> JS.concat(Tour.highlight_JS("[aria-label='Icon panel right']", clear: false))
                |> JS.push("activate_step", value: %{step: step.id})
              }
              class="btn btn-sm btn-soft"
            >
              <.icon name="hero-viewfinder-circle" class="size-4" /> Highlight
            </button>
          </:button>
          <:button :if={step.id == 6}>
            <button
              id={"tour-btn-#{step.id}"}
              disabled={step_disabled?(step.id, @completed_steps)}
              phx-click={
                Tour.spotlight_JS(step.target)
                |> JS.concat(Tour.highlight_JS(step.secondary_target, clear: false))
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
        <TourComponents.reload_debugger url={RoutesHelper.debugger_global_traces(self())} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("tick_counter", _params, socket) do
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end

  def handle_event("cycle_message", _params, socket) do
    {:noreply, assign(socket, :message, next_message(socket.assigns.message))}
  end

  def handle_event("add_item", _params, socket) do
    {:noreply, assign(socket, :items, append_item(socket.assigns.items))}
  end

  def handle_event("update_all", _params, socket) do
    {:noreply,
     socket
     |> update(:counter, &(&1 + 1))
     |> assign(:message, next_message(socket.assigns.message))
     |> assign(:items, append_item(socket.assigns.items))}
  end

  defp next_message(current) do
    idx = Enum.find_index(@messages, &(&1 == current)) || 0
    Enum.at(@messages, rem(idx + 1, length(@messages)))
  end

  defp append_item(items) when length(items) >= 5, do: ["Item 1"]

  defp append_item(items) do
    items ++ ["Item #{length(items) + 1}"]
  end

  defp step_disabled?(step_id, completed) when step_id > 4, do: not MapSet.member?(completed, 4)
  defp step_disabled?(step_id, completed) when step_id > 2, do: not MapSet.member?(completed, 2)
  defp step_disabled?(_, _), do: false

  attr :counter, :integer, required: true
  attr :message, :string, required: true
  attr :items, :list, required: true

  defp wire_payload_demo(assigns) do
    ~H"""
    <div
      id="wire-payload-demo"
      class="card bg-base-100 shadow-sm mb-6 mt-4 border border-base-300"
    >
      <div class="card-body">
        <h3 class="card-title text-base">
          <.icon name="hero-bolt" class="size-5 text-primary" /> Wire Payload Demo
        </h3>
        <p class="text-sm text-base-content/70">
          Each button mutates the LiveView state in a different shape. Watch the
          <b>Global Callbacks</b>
          panel: every click produces a <code>Diff sent</code>
          trace whose JSON body and byte-size badge mirror the change you just made.
        </p>

        <div class="flex flex-wrap items-center gap-3 mt-4">
          <div class="badge badge-lg badge-outline font-mono">
            counter: {@counter}
          </div>
          <div class="badge badge-lg badge-outline font-mono">
            message: "{@message}"
          </div>
          <div class="flex items-center gap-1">
            <span class="text-xs text-base-content/60 font-mono">items:</span>
            <%= if @items == [] do %>
              <span class="badge badge-sm badge-ghost font-mono">[]</span>
            <% else %>
              <span :for={item <- @items} class="badge badge-sm badge-neutral font-mono">
                {item}
              </span>
            <% end %>
          </div>
        </div>

        <div class="flex flex-wrap gap-2 mt-4">
          <button id="tick-counter" phx-click="tick_counter" class="btn btn-sm btn-soft">
            <.icon name="hero-plus" class="size-4" /> Tick counter
          </button>
          <button phx-click="cycle_message" class="btn btn-sm btn-soft btn-primary">
            <.icon name="hero-arrow-path" class="size-4" /> Cycle message
          </button>
          <button phx-click="add_item" class="btn btn-sm btn-soft btn-secondary">
            <.icon name="hero-plus-circle" class="size-4" /> Add item
          </button>
          <button phx-click="update_all" class="btn btn-sm btn-soft btn-accent">
            <.icon name="hero-sparkles" class="size-4" /> Update everything
          </button>
        </div>
      </div>
    </div>
    """
  end
end
