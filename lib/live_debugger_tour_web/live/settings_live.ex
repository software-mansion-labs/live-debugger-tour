defmodule LiveDebuggerTourWeb.Live.SettingsLive do
  use LiveDebuggerTourWeb, :live_view

  use LiveDebuggerTour.Page,
    number: 12,
    title: "Settings",
    description:
      "Tour the customization options that change how LiveDebugger behaves and how it surfaces dead views, traces, and memory pressure."

  alias LiveDebugger.Tour
  alias LiveDebugger.App.Web.Helpers.Routes, as: RoutesHelper
  alias LiveDebuggerTourWeb.Components.TourComponents
  alias Phoenix.LiveView.JS

  @tour_steps [
    %{
      id: 1,
      title: "Highlight components",
      description:
        "This is the toggle the <b>Components Tree</b> and <b>Active LiveViews</b> pages rely on to outline elements in your real browser tab when you hover a node in the debugger. Worth disabling if your page has hover styling that fights the overlay.",
      target: "div:has(> label > form > #highlight-in-browser-switch)",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-sparkles"
    },
    %{
      id: 2,
      title: "Show Debug Button",
      description:
        "With this off, the floating button disappears &ndash; but you can still open the debugger by visiting <code>localhost:4007</code> directly and picking the LiveView you want. The button is just a one-click shortcut.",
      target: "div:has(> label > form > #debug-button-switch)",
      action: {:highlight, [dismiss: "click-anywhere"]},
      icon: "hero-cursor-arrow-rays"
    },
    %{
      id: 3,
      title: "Enable DeadView mode",
      description:
        "Controls what happens when the LiveView you're inspecting dies. With it <b>ON</b>, the debugger pins to the dead process so you can browse its final assigns and last traces &ndash; the navbar swaps the green badge for a pink <b>Disconnected</b> one and shows a <b>Continue</b> button that jumps to the successor process. With it <b>OFF</b>, the debugger silently follows along to the new live process, so post-mortem inspection becomes impossible. " <>
          "(Page 4 of this tour actually triggers a crash if you want to see DeadView mode in action.)",
      target: "div:has(> label > form > #dead-view-mode-switch)",
      action: {:highlight, [dismiss: "click-target"]},
      icon: "hero-fire",
      demo: %{
        type: :highlight,
        target: :navbar_connected,
        title: "Where to look",
        description:
          "Click to highlight the navbar's connection badge — that's where the <b>Disconnected</b> indicator and <b>Continue</b> button appear once a LiveView dies with this mode on.",
        label: "Show indicator",
        icon: "hero-eye",
        button_icon: "hero-viewfinder-circle"
      }
    },
    %{
      id: 4,
      title: "Tracing enabled on start",
      description:
        "<b>OFF doesn't mean traces are lost</b> — they're always being captured behind the scenes. This setting only controls whether the live trace stream auto-starts when you open the debugger. " <>
          "Try it: toggle the switch off, jump to <b>Node Inspector</b> of this LiveView, click the demo button, then in the debugger click <b>Refresh</b> to load the trace you just generated. With the setting on, the trace would have streamed in live.",
      target: "div:has(> label > form > #tracing-enabled-on-start-switch)",
      action: {:highlight, [dismiss: "click-target"]},
      icon: "hero-play-pause",
      demo: %{
        type: :event,
        event: "increment",
        title: "Trigger a callback",
        description:
          "Each click runs a <code>handle_event</code> on this page — a single trace the debugger should pick up.",
        label: "Trigger handle_event",
        icon: "hero-bolt",
        button_icon: "hero-plus"
      }
    },
    %{
      id: 5,
      title: "Garbage Collection",
      description:
        "Marked <b>High impact</b> for a reason. With <b>ON</b>, LiveDebugger periodically trims old trace data (default ETS cap: 5GB per process) so memory stays bounded. With <b>OFF</b>, a warning indicator surfaces in the navbar and memory grows for as long as your app runs. Keep it on for long-running dev work; turn it off only for short, focused sessions where you want every historical trace preserved.",
      target: "div:has(> label > form > #garbage-collection-switch)",
      action: {:highlight, [dismiss: "click-target"]},
      icon: "hero-trash",
      demo: %{
        type: :spotlight,
        target: "div:has(> div > div > #gc-disabled-warning-tooltip)",
        title: "Where to look",
        description:
          "Click below — once you've turned GC off, a warning tooltip appears in this navbar slot to remind you that LiveDebugger is no longer trimming old data.",
        label: "Show warning",
        icon: "hero-eye",
        button_icon: "hero-viewfinder-circle"
      }
    },
    %{
      id: 6,
      title: "Refresh Tracing",
      description:
        "Reloads traced modules and reattaches the tracer to your callbacks. Reach for it after Phoenix hot-reloads code or after you recompile in IEx — those events can detach the tracer silently, so traces stop appearing for affected modules until you click this.",
      target: :refresh_tracing_button,
      action: {:spotlight, [dismiss: "click-anywhere"]},
      icon: "hero-arrow-path"
    }
  ]

  @default_settings %{
    dead_view_mode: true,
    garbage_collection: true,
    debug_button: true,
    tracing_enabled_on_start: true,
    dead_liveviews: false,
    highlight_in_browser: true
  }

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:counter, 0)
      |> tour_page_assigns(@tour_steps, redirect_url: RoutesHelper.settings())

    if connected?(socket) do
      Process.send_after(self(), :enable_settings, 500)
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <TourComponents.header
        number={@page_number}
        name={@page_title}
        description="Walk through what each LiveDebugger setting actually changes — including the navbar indicators and panel behaviors that aren't spelled out in the inline descriptions."
      />
      <TourComponents.progress_bar tour_steps={@tour_steps} completed_steps={@completed_steps} />

      <div class="alert alert-info mb-6">
        <.icon name="hero-information-circle" class="size-5" />
        <div>
          <p class="text-sm">
            Normally settings persist to disk between IEx sessions, and any value you also set in
            <code>config :live_debugger</code>
            takes precedence over what you toggle.
            However during LiveDebugger Tour they are disabled to change except this tutorial page.
            If you had LiveDebugger opened next to the tutorial you should be able to change settings now.
            However if they are still locked by the tour you can unlock them manually.
          </p>
        </div>
        <button
          id="tour-btn-1"
          phx-click={Tour.enable_settings_JS()}
          class="btn btn-sm btn-outline"
        >
          <.icon name="hero-lock-open" class="size-4" /> Unlock
        </button>
      </div>

      <div id="tour-cards" class="space-y-4">
        <TourComponents.tour_step
          :for={step <- @tour_steps}
          step={step}
          completed={MapSet.member?(@completed_steps, step.id)}
        >
          <:button :if={step.id == 4}>
            <div class="flex flex-col gap-3">
              <button
                id={"tour-btn-#{step.id}-2"}
                phx-click={
                  Tour.highlight_JS("div:has(> label > form > #tracing-enabled-on-start-switch)")
                  |> JS.push("activate_step", value: %{step: step.id})
                }
                class="btn btn-sm btn-soft"
              >
                <.icon name="hero-viewfinder-circle" class="size-4" /> Highlight
              </button>
              <button
                id={"tour-btn-#{step.id}-1"}
                phx-click={
                  RoutesHelper.debugger_node_inspector(self())
                  |> Tour.redirect_JS(
                    then: Tour.step(:highlight, "button[aria-label='Refresh traces']")
                  )
                }
                class="btn btn-sm btn-secondary"
              >
                <.icon name="hero-arrow-right-circle" class="size-4" /> Jump & Highlight
              </button>
            </div>
          </:button>
          <.interactive_demo_section :if={step[:demo]} demo={step.demo} counter={@counter} />
        </TourComponents.tour_step>
      </div>

      <TourComponents.clear_spotlight_button :if={@current_step != nil} />

      <div class="flex justify-center gap-3">
        <TourComponents.restart_page url={@page_path} />
        <TourComponents.reload_debugger on_click={
          Tour.redirect_JS(RoutesHelper.settings())
          |> JS.push("clear_tour")
          |> JS.push("enable_settings")
        } />
      </div>

      <TourComponents.navigation prev_page={@prev_page} next_page={@next_page} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end

  def handle_event("enable_settings", _params, socket) do
    Process.send_after(self(), :enable_settings, 500)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:enable_settings, socket) do
    Tour.enable_settings()

    parent_pid = self()

    spawn(fn ->
      Process.monitor(parent_pid)

      receive do
        {:DOWN, _ref, :process, _pid, _reason} ->
          @default_settings
          |> Enum.each(fn {key, value} -> LiveDebugger.API.SettingsStorage.save(key, value) end)

          Tour.disable_settings()

        _ ->
          :ok
      end
    end)

    {:noreply, socket}
  end

  attr :demo, :map, required: true
  attr :counter, :integer, required: true

  defp interactive_demo_section(assigns) do
    ~H"""
    <div class="card shadow-sm mt-4 border border-base-300">
      <div class="card-body p-4">
        <h3 class="card-title text-base">
          <.icon name={@demo.icon} class="size-5 text-primary" /> {@demo.title}
        </h3>

        <p class="text-sm text-base-content/70">
          {Phoenix.HTML.raw(@demo.description)}
        </p>

        <div class="flex items-center gap-4 mt-3">
          <div :if={@demo[:type] == :event} class="badge badge-lg badge-outline font-mono">
            counter: {@counter}
          </div>
          <button phx-click={demo_click(@demo)} class="btn btn-sm btn-soft">
            <.icon name={@demo.button_icon} class="size-4" /> {@demo.label}
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp demo_click(%{type: :event, event: event}), do: event
  defp demo_click(%{type: :highlight, target: target}), do: Tour.highlight_JS(target)

  defp demo_click(%{type: :spotlight, target: target}),
    do: Tour.spotlight_JS(target, dismiss: "click-anywhere")
end
