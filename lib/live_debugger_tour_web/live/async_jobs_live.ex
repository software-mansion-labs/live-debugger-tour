defmodule LiveDebuggerTourWeb.Live.AsyncJobsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 6,
    title: "Async Jobs",
    description:
      "Monitor your LiveView background jobs in real-time. Follow assign_async and start_async tasks from the moment they spawn until they resolve."

  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "Async Jobs Overview",
      description:
        "This section monitors background tasks spawned via <code>start_async/3</code> or <code>assign_async/3</code>. Jobs appear here while they are running and disappear the moment they complete.",
      target: "#async-jobs",
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-bolt"
    },
    %{
      id: 2,
      title: "Observing Pending State",
      description:
        "To properly observe an async job's lifecycle and its assigned PID, let's simulate a heavy operation. Trigger the slow task below and watch the debugger.",
      target: "#async-jobs",
      demo: %{
        event: "start_slow_async",
        label: "Slow Async (3s)",
        is_slow: true,
        description:
          "Deliberately pauses the background process for 3 seconds so you can inspect it."
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-clock"
    },
    %{
      id: 3,
      title: "Tracking assign_async",
      description:
        "LiveView's <code>assign_async</code> is great for loading data without blocking the UI. The debugger tracks these too, letting you know exactly which background operations are currently fetching data for your socket assigns.",
      target: "#async-jobs",
      demo: %{
        event: "start_assign_async",
        label: "Trigger assign_async",
        is_slow: true,
        description:
          "Simulates fetching background data for <code>@async_data</code> over 2 seconds."
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-arrow-path"
    },
    %{
      id: 4,
      title: "Task Cancellation",
      description:
        "If a parent process crashes, or if you manually abort a job using <code>cancel_async/2</code>, LiveDebugger instantly removes it from the active list to reflect the true state of your server memory.",
      target: "#async-jobs",
      demo: %{
        event: "start_cancelable_async",
        cancel_event: "cancel_job",
        label: "Start Cancelable Task",
        is_slow: true,
        description:
          "Starts a long running task. Click <b class='text-error'>Cancel</b> to abort it and watch it disappear from the debugger."
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-x-circle"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:async_status, "Idle")
      |> assign(:cancelable_loading, false)
      |> assign(:async_data, nil)
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
        description="Discover how to monitor your LiveView's background tasks. Open the debugger panel and follow the steps below to see how async jobs are tracked in real-time."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div id="tour-cards" class="space-y-4">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
        >
          <.interactive_demo_section
            :if={step[:demo]}
            demo={step.demo}
            async_status={@async_status}
            cancelable_loading={@cancelable_loading}
          />
        </TourComponents.tour_step>
      </div>

      <TourComponents.clear_spotlight_button :if={@current_step != nil} />

      <div class="flex justify-center gap-3">
        <TourComponents.restart_page url={@page_path} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("start_slow_async", _params, socket) do
    socket =
      socket
      |> assign(:async_status, "Running slow task (3s)...")
      |> start_async(:slow_task, fn ->
        Process.sleep(3000)
        {:ok, "Done"}
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("start_assign_async", _params, socket) do
    socket =
      socket
      |> assign(:async_status, "Fetching @async_data (2s)...")
      |> assign_async(:async_data, fn ->
        Process.sleep(2000)
        {:ok, %{async_data: "Loaded!"}}
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("start_cancelable_async", _params, socket) do
    socket =
      socket
      |> assign(:async_status, "Running cancelable task...")
      |> assign(:cancelable_loading, true)
      |> start_async(:cancelable_task, fn ->
        Process.sleep(10_000)
        {:ok, "Finished"}
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_job", _params, socket) do
    socket =
      socket
      |> cancel_async(:cancelable_task)
      |> assign(:cancelable_loading, false)
      |> assign(:async_status, "Task cancelled manually")

    {:noreply, socket}
  end

  @impl true
  def handle_async(:slow_task, {:ok, _result}, socket) do
    {:noreply, assign(socket, :async_status, "Slow task completed")}
  end

  @impl true
  def handle_async(:cancelable_task, {:ok, _result}, socket) do
    socket =
      socket
      |> assign(:cancelable_loading, false)
      |> assign(:async_status, "Cancelable task completed")

    {:noreply, socket}
  end

  @impl true
  def handle_async(:cancelable_task, {:exit, _reason}, socket) do
    socket =
      socket
      |> assign(:cancelable_loading, false)
      |> assign(:async_status, "Task exited unexpectedly")

    {:noreply, socket}
  end

  attr :async_status, :string, required: true
  attr :cancelable_loading, :boolean, default: false
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
          {if @demo.is_slow, do: "Execution Demo", else: "Interactive Demo"}
        </h3>

        <p class="text-sm text-base-content/70">
          {Phoenix.HTML.raw(@demo.description)}
        </p>

        <div class="flex items-center gap-4 mt-3">
          <div class="badge badge-lg badge-outline font-mono truncate max-w-[200px] sm:max-w-xs">
            status: {@async_status}
          </div>

          <button
            phx-click={@demo.event}
            phx-disable-with={
              if @demo.is_slow and not Map.has_key?(@demo, :cancel_event),
                do: "Processing...",
                else: nil
            }
            class="btn btn-sm btn-soft"
          >
            <.icon name={if @demo.is_slow, do: "hero-play", else: "hero-plus"} class="size-4" />
            {@demo.label}
          </button>

          <button
            :if={Map.get(@demo, :cancel_event) != nil and @cancelable_loading}
            phx-click={@demo.cancel_event}
            class="btn btn-sm btn-error"
          >
            <.icon name="hero-x-mark" class="size-4" /> Cancel
          </button>
        </div>
      </div>
    </div>
    """
  end
end
