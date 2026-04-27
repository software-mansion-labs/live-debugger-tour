defmodule LiveDebuggerTourWeb.Live.ActiveLiveViewsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 11,
    title: "Active LiveViews",
    description:
      "Use the dynamic dashboard to see all currently running LiveView processes across the application as they connect and disconnect."

  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents
  alias LiveDebuggerTourWeb.Live.ActiveLiveViews.WorkerLive

  @workers [
    %{id: "alpha", label: "Alpha", color: "primary", icon: "hero-bolt"},
    %{id: "beta", label: "Beta", color: "secondary", icon: "hero-cpu-chip"},
    %{id: "gamma", label: "Gamma", color: "accent", icon: "hero-sparkles"}
  ]

  @tour_steps [
    %{
      id: 1,
      title: "Active LiveViews panel",
      description:
        "Inside the panel, find the entry whose module is " <>
          "<code>ActiveLiveViewsLive</code> &ndash; that's this very page. " <>
          "Each entry shows the module, the PID, and the socket ID.",
      target: "#active-live-views",
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-rectangle-stack"
    },
    %{
      id: 2,
      title: "Spawn nested LiveViews",
      description:
        "Use the Worker Pool above to start one or more workers. " <>
          "Each worker is rendered with <code>live_render/3</code>, so it runs as its " <>
          "<span class=\"text-success font-bold\">own LiveView process</span> — " <>
          "and the dashboard refreshes the moment it spawns. Spawned workers appear " <>
          "<span class=\"text-success font-bold\">indented</span> under this page's entry.",
      target: "worker-pool",
      action: {:client_spotlight, []},
      icon: "hero-rocket-launch"
    },
    %{
      id: 3,
      title: "Inspect a worker",
      description:
        "<b>Click on any worker row in the dashboard.</b> " <>
          "The debugger navigates to that worker's Node Inspector, showing " <>
          "its assigns and traces — proof that each worker is a fully independent LiveView.",
      target: "#live-sessions ul > li > ul > li",
      action: {:highlight, [dismiss: "click-target"]},
      icon: "hero-arrow-right-circle"
    },
    %{
      id: 4,
      title: "Mutate the worker's state",
      description:
        "While viewing the worker in the debugger, come back here and click " <>
          "<span class=\"text-success font-bold\">Increment</span> on the corresponding card. " <>
          "Watch the worker's <code>tasks</code> assign change in real time — " <>
          "the debugger is attached to the child process, not to this page.",
      target: "worker-pool",
      action: {:client_spotlight, []},
      icon: "hero-arrow-trending-up"
    },
    %{
      id: 5,
      title: "Navigate to different LiveView",
      description:
        "Using Associated LiveViews panel you can quickly navigate between nested LiveViews and its parents.",
      target: "#associated-live-views",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-arrow-right-circle"
    },
    %{
      id: 6,
      title: "Return to the dashboard",
      description:
        "Use the navbar return button in the debugger to go back to the Active LiveViews dashboard.",
      target: :navbar_return_button,
      action: {:spotlight, [dismiss: "click-target"]},
      icon: "hero-arrow-uturn-left"
    },
    %{
      id: 7,
      title: "Dead LiveViews",
      description:
        "Right below the Active LiveViews panel sits the " <>
          "<span class=\"text-warning font-bold\">Dead LiveViews</span> section. " <>
          "When a process terminates, its final state is preserved here so you can inspect its " <>
          "<code>assigns</code> and callback traces post-mortem. " <>
          "Toggle workers off in the pool above and watch them land in this list. ",
      target: "#dead-live-views",
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-rectangle-stack"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(workers: @workers, active: MapSet.new())
      |> tour_page_assigns(@tour_steps, redirect_url: RoutesHelper.discovery())

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name={@page_title}
        description="Watch LiveView processes spawn and die in real time on the Active LiveViews dashboard."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div class="alert alert-info mb-6">
        <.icon name="hero-information-circle" class="size-5" />
        <div>
          <p class="font-semibold">What is the Active LiveViews dashboard?</p>
          <p class="text-sm">
            It lists every running LiveView process in your app, grouped by WebSocket
            connection, with parent/child relationships shown as an indented tree.
            The list refreshes automatically whenever a LiveView is born or dies.
          </p>
        </div>
      </div>

      <div id="worker-pool" class="card bg-base-100 shadow-sm mb-6">
        <div class="card-body">
          <h3 class="card-title text-base">
            <.icon name="hero-cog-6-tooth" class="size-5 text-primary" /> Worker Pool
          </h3>
          <p class="text-sm text-base-content/70">
            Toggle workers on or off below. Each active worker is rendered with
            <code>live_render/3</code>
            and runs as its own LiveView process.
          </p>

          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mt-4">
            <%= for worker <- @workers do %>
              <%= if MapSet.member?(@active, worker.id) do %>
                {live_render(@socket, WorkerLive,
                  id: "worker-#{worker.id}",
                  session: %{
                    "worker_id" => worker.id,
                    "label" => worker.label,
                    "color" => worker.color,
                    "icon" => worker.icon
                  }
                )}
              <% else %>
                <div class="card bg-base-200 border border-dashed border-base-300 p-4 min-h-32 grid place-items-center text-base-content/50">
                  <div class="flex flex-col items-center gap-1">
                    <.icon name={worker.icon} class="size-6 opacity-40" />
                    <span class="text-sm font-semibold">Worker {worker.label}</span>
                    <span class="text-xs">(off)</span>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>

          <div class="flex justify-center flex-wrap gap-2 mt-4 pt-4 border-t border-base-300">
            <button
              :for={worker <- @workers}
              phx-click="toggle_worker"
              phx-value-id={worker.id}
              class={[
                "btn btn-sm",
                if(MapSet.member?(@active, worker.id),
                  do: btn_class(worker.color),
                  else: "btn-ghost opacity-60"
                )
              ]}
            >
              <.icon name={worker.icon} class="size-4" />
              {worker.label}
            </button>
          </div>
        </div>
      </div>

      <div id="tour-cards" class="space-y-4">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
          disabled={step.id in [3, 4, 5, 6, 7] and not MapSet.member?(@completed_steps, 2)}
        />
      </div>

      <TourComponents.client_spotlight_hook />
      <TourComponents.clear_spotlight_button :if={@current_step != nil} />

      <div class="flex justify-center gap-3">
        <TourComponents.restart_page url={@page_path} />
        <TourComponents.reload_debugger url={RoutesHelper.discovery()} />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("toggle_worker", %{"id" => id}, socket) do
    active =
      if MapSet.member?(socket.assigns.active, id) do
        MapSet.delete(socket.assigns.active, id)
      else
        MapSet.put(socket.assigns.active, id)
      end

    {:noreply, assign(socket, :active, active)}
  end

  defp btn_class("primary"), do: "btn-primary"
  defp btn_class("secondary"), do: "btn-secondary"
  defp btn_class("accent"), do: "btn-accent"
  defp btn_class(_), do: "btn-soft"
end
