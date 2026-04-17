defmodule LiveDebuggerTourWeb.Live.ComponentsTree.WidgetCard do
  use LiveDebuggerTourWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:clicks, fn -> 0 end)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={["card shadow-sm border-l-4", @icon_color |> border_color_class()]}>
      <div class="card-body p-4">
        <div class="flex items-center gap-2">
          <.icon name={@icon} class={["size-5", @icon_color]} />
          <h4 class="font-semibold text-sm">{@label}</h4>
        </div>
        <p class="text-2xl font-bold mt-1">{@value}</p>
        <p class="text-xs text-base-content/60">{@description}</p>
        <div class="mt-2">
          <button phx-click="click" phx-target={@myself} class="btn btn-xs btn-ghost">
            <.icon name="hero-cursor-arrow-rays" class="size-3" /> Interact
            <span :if={@clicks > 0} class="badge badge-xs badge-primary">{@clicks}</span>
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("click", _params, socket) do
    {:noreply, assign(socket, :clicks, socket.assigns.clicks + 1)}
  end

  defp border_color_class("text-warning"), do: "border-warning"
  defp border_color_class("text-info"), do: "border-info"
  defp border_color_class("text-success"), do: "border-success"
  defp border_color_class("text-error"), do: "border-error"
  defp border_color_class("text-primary"), do: "border-primary"
  defp border_color_class("text-secondary"), do: "border-secondary"
  defp border_color_class(_), do: "border-base-300"
end
