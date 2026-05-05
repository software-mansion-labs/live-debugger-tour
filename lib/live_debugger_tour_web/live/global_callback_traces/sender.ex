defmodule LiveDebuggerTourWeb.Live.GlobalCallbackTraces.Sender do
  @moduledoc false
  use LiveDebuggerTourWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="p-4 border border-base-200 rounded-lg bg-base-200/30 flex flex-col items-center justify-center text-center h-32 relative">
      <span class="absolute top-2 left-2 text-xs font-mono text-base-content/50">CID: {@id}</span>
      <h4 class="font-bold mb-2 flex items-center gap-2">
        <.icon name="hero-paper-airplane" class="size-4 text-info" /> Sender
      </h4>
      <button phx-click="send_ping" phx-target={@myself} class="btn btn-sm btn-info">
        Send Ping
      </button>
    </div>
    """
  end

  def handle_event("send_ping", _params, socket) do
    timestamp = :os.system_time(:millisecond)
    send(self(), {:ping_from_sender, "Hello from Sender!", timestamp})

    {:noreply, socket}
  end
end
