defmodule LiveDebuggerTourWeb.Live.StreamsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 7,
    title: "Streams",
    description:
      "Monitor how Phoenix Streams manage large collections. Watch stream operations like insert, update, and delete happen in real-time."

  alias LiveDebuggerTourWeb.Components.TourComponents
  alias Phoenix.LiveView.JS

  @tour_steps [
    %{
      id: 1,
      title: "Stream Preview",
      description:
        "Before we begin, let's open the Stream Preview. Look for the floating button on the <span class=\"text-primary font-bold\">right edge of the screen</span>. Click it to slide out a panel that will show you exactly how the UI reacts to your stream operations.",
      target: "stream-preview-button",
      action: {:client_spotlight, []},
      icon: "hero-view-columns"
    },
    %{
      id: 2,
      title: "Streams Overview",
      description:
        "This section lists all streams managed by your LiveView. Streams handle large lists efficiently by keeping them strictly on the client. The debugger automatically tracks all registered streams here.",
      target: "#streams-section-container",
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-rectangle-group"
    },
    %{
      id: 3,
      title: "Insertions",
      description:
        "LiveDebugger intercepts all stream payloads. Try inserting a new item below and watch it appear in the debugger.",
      target: "#streams-section-container",
      demo: %{
        event: "insert_item",
        label: "Insert Item",
        icon: "hero-plus",
        color: "btn-primary"
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-bars-arrow-down"
    },
    %{
      id: 4,
      title: "DOM Highlighting",
      description:
        "<b>Hover your mouse over the newly inserted item inside the debugger panel</b>, and you'll see the corresponding HTML element highlighted directly in the Stream Preview.",
      target: "#tour_items-stream > :first-child",
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-cursor-arrow-rays"
    },
    %{
      id: 5,
      title: "Updates",
      description:
        "When you update an existing item using <code>stream_insert/4</code>, LiveView identifies it by its DOM ID and patches only that specific element. Click the button below to update the last inserted item and spot the change indicator.",
      target: "#streams-section-container",
      demo: %{
        event: "update_item",
        label: "Update Last Item",
        icon: "hero-arrow-path",
        color: "btn-secondary"
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-pencil-square"
    },
    %{
      id: 6,
      title: "Deletions",
      description:
        "Removing items is just as efficient. Triggering <code>stream_delete/3</code> tells the client to drop the element. Try deleting the last item and watch it vanish from the tracking list.",
      target: "#streams-section-container",
      demo: %{
        event: "delete_item",
        label: "Delete Last Item",
        icon: "hero-trash",
        color: "btn-error"
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-minus-circle"
    },
    %{
      id: 7,
      title: "Trace Integration",
      description:
        "LiveDebugger extracts all stream operations directly from LiveView lifecycle traces. Try triggering an action below, and look at the trace in the debugger. You'll see exactly which callback rendered the stream mutation.",
      target: :callback_traces_first_trace,
      demo: %{
        event: "insert_item",
        label: "Insert Item",
        icon: "hero-plus",
        color: "btn-primary"
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-cpu-chip"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_id, 0)
      |> stream(:tour_items, [])
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
        description="Learn how to inspect Phoenix Streams. Open the debugger panel and use the interactive buttons below to perform stream operations."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <.stream_preview_panel streams={@streams} />

      <div id="tour-cards" class="space-y-4 relative z-10">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
        >
          <.interactive_demo_section :if={step[:demo]} demo={step.demo} />
        </TourComponents.tour_step>
      </div>

      <TourComponents.client_spotlight_hook />
      <TourComponents.clear_spotlight_button :if={@current_step != nil} />

      <div class="flex justify-center gap-3 mt-8">
        <TourComponents.restart_page url={@page_path} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("insert_item", _params, socket) do
    next_id = socket.assigns.current_id
    item = %{id: next_id, value: "Item #{next_id}", random: Enum.random(1..100)}

    socket =
      socket
      |> stream_insert(:tour_items, item, at: -1)
      |> assign(:current_id, next_id + 1)

    {:noreply, socket}
  end

  def handle_event("update_item", _params, socket) do
    last_id = socket.assigns.current_id - 1

    if last_id >= 0 do
      updated_item = %{
        id: last_id,
        value: "Item #{last_id} (Updated)",
        random: Enum.random(1..100)
      }

      socket = stream_insert(socket, :tour_items, updated_item)
      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "No items to update!")}
    end
  end

  def handle_event("delete_item", _params, socket) do
    last_id = socket.assigns.current_id - 1

    if last_id >= 0 do
      item_to_delete = %{id: last_id}

      socket =
        socket
        |> stream_delete(:tour_items, item_to_delete)
        |> assign(:current_id, last_id)

      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "No items to delete!")}
    end
  end

  attr :demo, :map, required: true

  defp interactive_demo_section(assigns) do
    ~H"""
    <div class="card shadow-sm mt-4 border border-base-300">
      <div class="card-body p-4">
        <div class="flex items-center gap-4">
          <button
            phx-click={@demo.event}
            class={["btn btn-sm", @demo.color]}
          >
            <.icon name={@demo.icon} class="size-4" />
            {@demo.label}
          </button>
        </div>
      </div>
    </div>
    """
  end

  attr :streams, :any, required: true

  defp stream_preview_panel(assigns) do
    ~H"""
    <div class="fixed right-0 top-1/3 z-[9999]">
      <button
        id="stream-preview-button"
        class="btn btn-primary shadow-lg rounded-r-none pl-3 pr-4 py-2 flex items-center gap-2 hover:pr-6 transition-all"
        phx-click={JS.remove_class("translate-x-full", to: "#stream-side-panel")}
      >
        <.icon name="hero-chevron-left" class="size-4" /> Preview
      </button>
    </div>

    <div
      id="stream-side-panel"
      class="fixed right-0 top-0 h-full w-80 bg-base-100 shadow-2xl z-[10000] transform transition-transform duration-300 translate-x-full border-l border-base-300 flex flex-col"
    >
      <div class="p-4 border-b border-base-200 flex justify-between items-center bg-base-200/50">
        <h3 class="font-bold text-lg flex items-center gap-2">
          <.icon name="hero-list-bullet" class="size-5 text-primary" /> Stream Preview
        </h3>
        <button
          class="btn btn-sm btn-circle btn-ghost"
          phx-click={JS.add_class("translate-x-full", to: "#stream-side-panel")}
        >
          <.icon name="hero-x-mark" class="size-5" />
        </button>
      </div>

      <div class="p-4 flex-1 overflow-y-auto bg-base-100">
        <p class="text-xs text-base-content/70 mb-4 pb-2 border-b border-base-200">
          This panel reflects the true state of the UI. Watch it update instantly as you complete the tour steps.
        </p>

        <ul id="tour-stream-preview" phx-update="stream" class="flex flex-col gap-2">
          <li
            :for={{dom_id, item} <- @streams.tour_items}
            id={dom_id}
            class="p-3 bg-base-100 border border-base-200 rounded shadow-sm flex justify-between items-center animate-in fade-in slide-in-from-right-4"
          >
            <div class="flex flex-col">
              <span class="font-bold text-sm">{item.value}</span>
              <span class="font-mono text-xs text-base-content/50">ID: {dom_id}</span>
            </div>
            <span class="badge badge-ghost badge-sm">R: {item.random}</span>
          </li>

          <li
            id="empty-stream-state"
            class="text-center text-sm text-base-content/50 my-8 only:block hidden"
          >
            Stream is empty.<br />Click "Insert Item" in the tour.
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
