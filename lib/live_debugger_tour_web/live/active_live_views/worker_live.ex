defmodule LiveDebuggerTourWeb.Live.ActiveLiveViews.WorkerLive do
  @moduledoc """
  Nested LiveView spawned per active worker on the Active LiveViews tour page.

  Each running instance is its own process with independent state, so it appears
  as a child node in LiveDebugger's Active LiveViews dashboard.
  """
  use LiveDebuggerTourWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign(socket,
        worker_id: session["worker_id"],
        label: session["label"],
        color: session["color"],
        icon: session["icon"],
        tasks: 0
      )

    {:ok, socket, layout: false}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={["card shadow-sm bg-base-100 border-l-4", border_class(@color)]}>
      <div class="card-body p-4">
        <div class="flex items-center gap-2">
          <.icon name={@icon} class={["size-5", text_class(@color)]} />
          <h4 class="font-semibold text-sm">Worker {@label}</h4>
          <span class="badge badge-success badge-xs ml-auto">live</span>
        </div>
        <p class="text-2xl font-bold mt-1 font-mono">tasks: {@tasks}</p>
        <p class="text-xs text-base-content/60">
          Independent LiveView process
        </p>
        <div class="mt-2">
          <button phx-click="increment" class={["btn btn-sm btn-outline", btn_class(@color)]}>
            <.icon name="hero-plus" class="size-4" /> Increment
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, :tasks, socket.assigns.tasks + 1)}
  end

  defp border_class("primary"), do: "border-primary"
  defp border_class("secondary"), do: "border-secondary"
  defp border_class("accent"), do: "border-accent"
  defp border_class(_), do: "border-base-300"

  defp text_class("primary"), do: "text-primary"
  defp text_class("secondary"), do: "text-secondary"
  defp text_class("accent"), do: "text-accent"
  defp text_class(_), do: "text-base-content"

  defp btn_class("primary"), do: "btn-primary"
  defp btn_class("secondary"), do: "btn-secondary"
  defp btn_class("accent"), do: "btn-accent"
  defp btn_class(_), do: ""
end
