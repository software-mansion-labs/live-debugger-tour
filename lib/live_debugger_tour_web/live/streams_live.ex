defmodule LiveDebuggerTourWeb.Live.StreamsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 7,
    title: "Streams",
    description:
      "Monitor how Phoenix Streams manage large collections. Watch stream operations like insert, update, and delete happen in real-time without bloating the socket state."

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents

  @tour_steps [
    %{
      id: 1,
      title: "Live Stream Preview",
      description:
        "On the <span class=\"text-primary font-bold\">left side</span>, you'll find the Live Stream Preview. This panel reflects the true state of the UI. Watch it update instantly as you trigger actions in the steps below.",
      target: "#stream-preview-card",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-view-columns"
    },
    %{
      id: 2,
      title: "Stream Insertions",
      description:
        "Streams keep large collections out of server memory by storing them on the client. LiveDebugger intercepts these payloads. Try inserting a new item below and watch it appear in the debugger's Streams section.",
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
      id: 3,
      title: "Stream Updates",
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
      id: 4,
      title: "Stream Deletions",
      description:
        "Removing items is just as efficient. Triggering <code>stream_delete/3</code> tells the client to drop the element. Try deleting the last item and watch it vanish from the debugger's tracking list.",
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
      id: 5,
      title: "Stream Resets",
      description:
        "Sometimes you need to fetch a fresh list or clear the UI. Passing the <code>reset: true</code> option completely flushes the client's collection. Try resetting the stream below.",
      target: "#streams-section-container",
      demo: %{
        event: "reset_stream",
        label: "Reset Stream",
        icon: "hero-arrow-path-rounded-square",
        color: "btn-warning"
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-archive-box-x-mark"
    },
    %{
      id: 6,
      title: "Trace Integration",
      description:
        "LiveDebugger extracts all stream operations directly from LiveView lifecycle events. Try triggering an action below, and look at the highlighted trace in the debugger. You'll see exactly which callback rendered the stream mutation.",
      target: :callback_traces_first_trace,
      demo: %{
        event: "insert_item",
        label: "Trigger Trace",
        icon: "hero-bolt",
        color: "btn-accent"
      },
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-cpu-chip"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      self()
      |> RoutesHelper.debugger_node_inspector()
      |> LiveDebugger.Tour.redirect()
    end

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

      <%!-- UKŁAD DWUKOLUMNOWY --%>
      <div class="flex flex-col lg:flex-row gap-6 mt-6 items-start relative z-10">
        <%!-- LEWA KOLUMNA: PLAYGROUND (Sticky) --%>
        <div
          id="stream-preview-card"
          class="w-full lg:w-1/3 card bg-base-100 shadow-sm border border-base-300 lg:sticky lg:top-6"
        >
          <div class="card-body p-4">
            <h3 class="font-bold text-lg flex items-center gap-2 border-b border-base-200 pb-3 mb-2">
              <.icon name="hero-list-bullet" class="size-5 text-primary" /> Live Stream Preview
            </h3>

            <%!-- Kontener o stałej maksymalnej wysokości ze scrollem --%>
            <div class="overflow-y-auto max-h-[350px] pr-2">
              <ul
                id="tour-stream-preview"
                phx-update="stream"
                class="flex flex-col gap-2 min-h-[100px]"
              >
                <li
                  :for={{dom_id, item} <- @streams.tour_items}
                  id={dom_id}
                  class="p-3 bg-base-200/50 border border-base-300 rounded shadow-sm flex justify-between items-center animate-in fade-in slide-in-from-left-4"
                >
                  <div class="flex flex-col">
                    <span class="font-bold text-sm">{item.value}</span>
                    <span class="font-mono text-xs text-base-content/50">ID: {dom_id}</span>
                  </div>
                  <span class="badge badge-ghost badge-sm">R: {item.random}</span>
                </li>

                <div
                  id="empty-stream-state"
                  class="text-center text-sm text-base-content/50 my-12 only:block hidden"
                >
                  Stream is empty.<br />Click "Insert Item" on the right.
                </div>
              </ul>
            </div>
          </div>
        </div>

        <%!-- PRAWA KOLUMNA: KARTY SAMOUCZKA --%>
        <div id="tour-cards" class="w-full lg:w-2/3 space-y-4">
          <TourComponents.tour_step
            :for={step <- @tour_steps}
            step={step}
            completed={MapSet.member?(@completed_steps, step.id)}
          >
            <.interactive_demo_section :if={step[:demo]} demo={step.demo} />
          </TourComponents.tour_step>
        </div>
      </div>

      <TourComponents.clear_spotlight_button :if={@current_step != nil} />

      <div class="flex justify-center gap-3 mt-12">
        <TourComponents.restart_page url={@page_path} />
        <TourComponents.reload_debugger url={RoutesHelper.debugger_node_inspector(self())} />
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

  @impl true
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

  @impl true
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

  @impl true
  def handle_event("reset_stream", _params, socket) do
    socket =
      socket
      |> stream(:tour_items, [], reset: true)
      |> assign(:current_id, 0)

    {:noreply, socket}
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
end
