defmodule LiveDebuggerTourWeb.Live.ComponentsTreeLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 5,
    title: "Components Tree",
    description:
      "Visualize complex UI hierarchies with multiple LiveComponents, using the highlight feature to map the tree structure to the browser view."

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents
  alias LiveDebuggerTourWeb.Live.ComponentsTree.WidgetCard

  @initial_widgets [
    %{
      id: "weather",
      label: "Weather",
      icon: "hero-sun",
      icon_color: "text-warning",
      value: "24°C",
      description: "Current temperature"
    },
    %{
      id: "visitors",
      label: "Visitors",
      icon: "hero-users",
      icon_color: "text-info",
      value: "1,429",
      description: "Active users"
    },
    %{
      id: "uptime",
      label: "Uptime",
      icon: "hero-arrow-trending-up",
      icon_color: "text-success",
      value: "99.9%",
      description: "System uptime"
    },
    %{
      id: "alerts",
      label: "Alerts",
      icon: "hero-bell-alert",
      icon_color: "text-error",
      value: "3 new",
      description: "Pending alerts"
    }
  ]

  @tour_steps [
    %{
      id: 1,
      title: "Open the Components Tree",
      description:
        "In the LiveDebugger panel, find and open the Components Tree view. " <>
          "This panel shows a hierarchical tree of all LiveComponents rendered by the current LiveView.",
      target: "#components-tree",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-rectangle-group"
    },
    %{
      id: 2,
      title: "Explore the dashboard",
      description:
        "The widget dashboard below contains multiple LiveComponents. " <>
          "Each card is a separate <code>WidgetCard</code> component with its own CID (Component ID) in the debugger tree.",
      target: "widget-dashboard",
      action: {:client_spotlight, []},
      icon: "hero-squares-2x2"
    },
    %{
      id: 3,
      title: "Hover to highlight",
      description:
        "Hovering over a node in the Components Tree highlights the corresponding DOM element in the browser. " <>
          "Try hovering over different widget entries to see which card lights up.",
      target: "#components-tree",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-cursor-arrow-rays"
    },
    %{
      id: 4,
      title: "Toggle widgets",
      description:
        "Use the toggle buttons below the dashboard to show or hide widgets. " <>
          "Watch the Components Tree update in real-time as LiveComponents are added and removed from the page.",
      target: "widget-controls",
      action: {:client_spotlight, []},
      icon: "hero-eye-slash"
    },
    %{
      id: 5,
      title: "Add new components",
      description:
        "Click the \"Add Widget\" button to dynamically create a new LiveComponent. " <>
          "A new CID entry will appear in the Components Tree. Each widget also has local state you can inspect.",
      target: "add-widget-button",
      action: {:client_spotlight, []},
      icon: "hero-plus-circle"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    initial_ids = MapSet.new(@initial_widgets, & &1.id)

    socket =
      socket
      |> tour_page_assigns(@tour_steps)
      |> assign(
        widgets: @initial_widgets,
        visible: initial_ids,
        widget_counter: length(@initial_widgets)
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name={@page_title}
        description="Visualize complex UI hierarchies with multiple LiveComponents, using the highlight feature to map the tree structure to the browser view."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div class="alert alert-info mb-6">
        <.icon name="hero-information-circle" class="size-5" />
        <div>
          <p class="font-semibold">What is the Components Tree?</p>
          <p class="text-sm">
            The Components Tree shows the hierarchy of all LiveComponents rendered inside
            a LiveView. Each component gets a unique CID (Component ID) that you can click
            to inspect its assigns, state, and rendered output. Hovering a node highlights
            the corresponding element in the browser.
          </p>
        </div>
      </div>

      <div id="widget-dashboard" class="card bg-base-100 shadow-sm mb-6">
        <div class="card-body">
          <h3 class="card-title text-base">
            <.icon name="hero-squares-2x2" class="size-5 text-primary" /> Widget Dashboard
          </h3>
          <p class="text-sm text-base-content/70">
            Each widget below is a LiveComponent with its own CID in the debugger tree.
            Click "Interact" to create local state changes visible in the assigns inspector.
          </p>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4">
            <.live_component
              :for={widget <- @widgets}
              :if={MapSet.member?(@visible, widget.id)}
              module={WidgetCard}
              id={"widget-#{widget.id}"}
              label={widget.label}
              icon={widget.icon}
              icon_color={widget.icon_color}
              value={widget.value}
              description={widget.description}
            />
          </div>
          <div
            id="widget-controls"
            class="flex bg-base-100 flex-wrap gap-2 mt-4 pt-4 border-t border-base-300"
          >
            <button
              :for={widget <- @widgets}
              phx-click="toggle_widget"
              phx-value-id={widget.id}
              class={[
                "btn btn-sm",
                if(MapSet.member?(@visible, widget.id), do: "btn-soft", else: "btn-ghost opacity-50")
              ]}
            >
              <.icon name={widget.icon} class="size-4" />
              {widget.label}
            </button>
            <button
              id="add-widget-button"
              phx-click="add_widget"
              class="btn btn-sm btn-outline bg-base-100"
            >
              <.icon name="hero-plus" class="size-4" /> Add Widget
            </button>
          </div>
        </div>
      </div>

      <div id="tour-cards" class="space-y-4">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
          disabled={step.id != 1 and not MapSet.member?(@completed_steps, 1)}
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

  @new_widget_templates [
    %{
      label: "Storage",
      icon: "hero-circle-stack",
      icon_color: "text-secondary",
      value: "82%",
      description: "Disk usage"
    },
    %{
      label: "CPU",
      icon: "hero-cpu-chip",
      icon_color: "text-primary",
      value: "47%",
      description: "Processor load"
    },
    %{
      label: "Memory",
      icon: "hero-server",
      icon_color: "text-warning",
      value: "3.2 GB",
      description: "RAM used"
    },
    %{
      label: "Network",
      icon: "hero-globe-alt",
      icon_color: "text-info",
      value: "120 ms",
      description: "Avg latency"
    },
    %{
      label: "Errors",
      icon: "hero-exclamation-triangle",
      icon_color: "text-error",
      value: "7",
      description: "Last hour"
    },
    %{
      label: "Tasks",
      icon: "hero-clipboard-document-check",
      icon_color: "text-success",
      value: "12",
      description: "Running jobs"
    }
  ]

  @impl true
  def handle_event("toggle_widget", %{"id" => id}, socket) do
    visible =
      if MapSet.member?(socket.assigns.visible, id) do
        MapSet.delete(socket.assigns.visible, id)
      else
        MapSet.put(socket.assigns.visible, id)
      end

    {:noreply, assign(socket, :visible, visible)}
  end

  @impl true
  def handle_event("add_widget", _params, socket) do
    counter = socket.assigns.widget_counter
    template = Enum.at(@new_widget_templates, rem(counter, length(@new_widget_templates)))
    new_id = "custom-#{counter + 1}"

    new_widget = Map.put(template, :id, new_id)

    {:noreply,
     socket
     |> assign(:widgets, socket.assigns.widgets ++ [new_widget])
     |> assign(:visible, MapSet.put(socket.assigns.visible, new_id))
     |> assign(:widget_counter, counter + 1)}
  end
end
