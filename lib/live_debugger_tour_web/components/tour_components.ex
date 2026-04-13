defmodule LiveDebuggerTourWeb.Components.TourComponents do
  @moduledoc """
  Provides UI components for tour pages.
  """
  use LiveDebuggerTourWeb, :html

  alias LiveDebugger.Tour

  attr :number, :integer, required: true
  attr :name, :string, required: true
  attr :description, :string, required: true

  def header(assigns) do
    ~H"""
    <div class="text-center mb-8">
      <div class="badge badge-primary badge-lg mb-3">Page {@number}</div>
      <h1 class="text-3xl font-bold mb-2">{@name}</h1>
      <p class="text-base-content/70 max-w-lg mx-auto">{@description}</p>
    </div>
    """
  end

  attr :step, :map, required: true
  attr :completed, :boolean, required: true

  def tour_step(assigns) do
    ~H"""
    <div
      id={"tour-step-#{@step.id}"}
      class={[
        "card bg-base-200 shadow-sm transition-all duration-200",
        if(@completed, do: "ring-2 ring-success")
      ]}
    >
      <div class="card-body">
        <div class="flex items-center gap-3">
          <div class={[
            "rounded-full p-2",
            if(@completed, do: "bg-success/20 text-success", else: "bg-primary/10 text-primary")
          ]}>
            <%= if @completed do %>
              <.icon name="hero-check" class="size-5" />
            <% else %>
              <.icon name={@step.icon} class="size-5" />
            <% end %>
          </div>
          <div class="flex-1">
            <h3 class="card-title text-base">{@step.title}</h3>
            <p class="text-sm text-base-content/70">{@step.description}</p>
            <code
              :if={@step[:code_snippet]}
              class="block mt-2 px-3 py-2 text-xs bg-base-300 rounded-lg font-mono select-all"
            >
              {@step.code_snippet}
            </code>
          </div>
          <button
            id={"tour-btn-#{@step.id}"}
            phx-click={tour_action(@step) |> JS.push("activate_step", value: %{step: @step.id})}
            class={[
              "btn btn-sm",
              "btn-soft"
            ]}
          >
            <.icon name="hero-viewfinder-circle" class="size-4" /> Spotlight
          </button>
        </div>
      </div>
    </div>
    """
  end

  attr :tour_steps, :list, required: true
  attr :completed_steps, MapSet, required: true

  def progress_bar(assigns) do
    ~H"""
    <ul id="tour-progress" class="steps steps-horizontal w-full mb-8">
      <%= for step <- @tour_steps do %>
        <li class={[
          "step",
          if(MapSet.member?(@completed_steps, step.id), do: "step-success")
        ]}>
          {step.title}
        </li>
      <% end %>
    </ul>
    """
  end

  def clear_spotlight_button(assigns) do
    ~H"""
    <div id="clear-tour" class="text-center mt-4">
      <button
        id="clear-tour-btn"
        phx-click={clear_all_spotlights()}
        class="btn btn-outline btn-sm"
      >
        <.icon name="hero-x-mark" class="size-4" /> Clear spotlight
      </button>
    </div>
    """
  end

  @doc """
  Renders a hidden hook element that handles client-side spotlights.
  Uses the same overlay + spotlight-target CSS as LiveDebugger's tour.
  Include this on any page that uses `action: :client_spotlight` steps.
  """
  def client_spotlight_hook(assigns) do
    ~H"""
    <div id="client-spotlight-hook" phx-hook=".ClientSpotlight" class="hidden" phx-update="ignore">
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".ClientSpotlight">
      const OVERLAY_ID = 'client-tour-overlay';

      function clearAll() {
        const overlay = document.getElementById(OVERLAY_ID);
        if (overlay) overlay.remove();
        document.querySelectorAll('.tour-spotlight-target')
          .forEach(el => el.classList.remove('tour-spotlight-target'));
      }

      function createOverlay() {
        if (!document.getElementById(OVERLAY_ID)) {
          const overlay = document.createElement('div');
          overlay.id = OVERLAY_ID;
          overlay.className = 'tour-overlay';
          overlay.addEventListener('click', (e) => e.stopPropagation());
          document.body.appendChild(overlay);
        }
      }

      export default {
        mounted() {
          const controller = new AbortController();
          this._cleanup = null;

          const handler = () => {
            clearAll();
            this._cleanup = null;
          };

          this._cleanup = () => controller.abort();

          this.el.addEventListener('tour:client-spotlight', (e) => {
            const { target } = e.detail;
            clearAll();
            createOverlay();
            const el = document.getElementById(target);
            if (el) {
              el.classList.add('tour-spotlight-target');

              setTimeout(() => {
                if (!controller.signal.aborted) {
                  el.addEventListener('click', handler, {
                    once: true,
                    signal: controller.signal,
                  });
                }
              }, 0);
            }

          });

          this.el.addEventListener('tour:client-clear', () => {
            clearAll();
          });
        },
        destroyed() {
          this._cleanup();
          clearAll();
        }
      }
    </script>
    """
  end

  attr :prev_page, :string, required: true
  attr :next_page, :string, required: true

  def navigation(assigns) do
    ~H"""
    <div
      id="page-navigation"
      class="flex justify-between items-center mt-10 pt-6 border-t border-base-300"
    >
      <.link navigate={@prev_page} class="btn btn-ghost btn-sm">
        <.icon name="hero-arrow-left" class="size-4" />
        <%= if @prev_page == ~p"/" do %>
          Back Home
        <% else %>
          Previous Page
        <% end %>
      </.link>
      <.link :if={@next_page} navigate={@next_page} class="btn btn-ghost btn-sm">
        Next Page <.icon name="hero-arrow-right" class="size-4" />
      </.link>
    </div>
    """
  end

  attr :url, :string, required: true

  def restart_page(assigns) do
    ~H"""
    <div id="restart-page" class="text-center mt-4">
      <.link
        id="restart-page-btn"
        navigate={@url}
        class="btn btn-soft btn-sm"
      >
        Restart Page
      </.link>
    </div>
    """
  end

  attr :url, :string, required: true

  def reload_debugger(assigns) do
    ~H"""
    <div id="reload-debugger" class="text-center mt-4">
      <button
        id="reload-debugger-btn"
        phx-click={Tour.redirect_JS(@url) |> JS.push("clear_tour")}
        class="btn btn-soft btn-sm"
      >
        Reload LiveDebugger
      </button>
    </div>
    """
  end

  defp tour_action(%{action: :client_spotlight, target: target}) do
    JS.dispatch("tour:client-spotlight",
      to: "#client-spotlight-hook",
      detail: %{target: target}
    )
  end

  defp tour_action(%{action: :spotlight, target: target, dismiss: dismiss}),
    do: Tour.spotlight_JS(target, dismiss)

  defp tour_action(%{action: :spotlight, target: target}), do: Tour.spotlight_JS(target)

  defp tour_action(%{action: :highlight, target: target}), do: Tour.highlight(target)

  defp clear_all_spotlights do
    Tour.clear_JS()
    |> JS.dispatch("tour:client-clear", to: "#client-spotlight-hook")
    |> JS.push("clear_tour")
  end
end
