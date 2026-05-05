defmodule LiveDebuggerTourWeb.Live.GlobalCallbackTraces.Receiver do
  @moduledoc false
  use LiveDebuggerTourWeb, :live_component

  def update(%{new_message: {msg, ts}}, socket) do
    formatted_time =
      DateTime.from_unix!(ts, :millisecond)
      |> Calendar.strftime("%H:%M:%S")

    new_log = "[#{formatted_time}] #{msg}"

    {:ok, update(socket, :logs, fn logs -> Enum.take([new_log | logs], 3) end)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:logs, fn -> [] end)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-4 border border-base-200 rounded-lg bg-base-200/30 flex flex-col h-32 relative overflow-hidden">
      <span class="absolute top-2 left-2 text-xs font-mono text-base-content/50">CID: {@id}</span>
      <h4 class="font-bold mb-2 flex items-center gap-2 justify-center">
        <.icon name="hero-inbox-arrow-down" class="size-4 text-success" /> Receiver
      </h4>

      <div class="flex-1 overflow-y-auto flex flex-col gap-1 items-center">
        <div :if={@logs == []} class="text-xs text-base-content/40 italic mt-2">
          Waiting for messages...
        </div>
        <div
          :for={log <- @logs}
          class="text-xs font-mono bg-base-100 px-2 py-1 rounded border border-base-300 w-full truncate text-center animate-in fade-in slide-in-from-top-2"
        >
          {log}
        </div>
      </div>
    </div>
    """
  end
end
