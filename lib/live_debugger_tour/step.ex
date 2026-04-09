defmodule LiveDebuggerTour.Step do
  @moduledoc """
  Macro for declaring a LiveView tutorial step.

  Provides step metadata for auto-discovery, shared mount logic via
  `step_assigns/2`, and lifecycle hooks for tour interaction.

  Completed steps are persisted in the URL query string (`?completed=1,2,3`)
  so progress survives page refresh.

  ## Usage

      defmodule LiveDebuggerTourWeb.Live.HelloWorldLive do
        use LiveDebuggerTourWeb, :live_view
        use LiveDebuggerTour.Step,
          number: 1,
          title: "Hello World",
          description: "Your first LiveView",
          path: "/steps/hello-world"

        @tour_steps [...]

        @impl true
        def mount(_params, _session, socket) do
          {:ok, step_assigns(socket, @tour_steps, redirect_url: "..."}
        end

        @impl true
        def render(assigns) do
          ~H"..."
        end
      end
  """

  @required_keys [:number, :title, :description, :path]

  defmacro __using__(opts) do
    missing = @required_keys -- Keyword.keys(opts)

    if missing != [] do
      raise ArgumentError, "missing required Step keys: #{inspect(missing)}"
    end

    quote do
      def __step_meta__ do
        Map.new(unquote(opts))
      end

      @doc false
      def step_assigns(socket, tour_steps, opts \\ []) do
        meta = __step_meta__()

        LiveDebuggerTour.Step.step_assigns(socket, tour_steps, meta, opts)
      end
    end
  end

  def step_assigns(socket, tour_steps, meta, opts \\ []) do
    if Phoenix.LiveView.connected?(socket) do
      url =
        Keyword.get_lazy(opts, :redirect_url, fn ->
          LiveDebugger.App.Web.Helpers.Routes.debugger_node_inspector(self())
        end)

      LiveDebugger.Tour.redirect(url)
    end

    {prev_page, next_page} = LiveDebuggerTour.StepDiscovery.step_navigation(meta.number)

    socket
    |> Phoenix.Component.assign(
      page_title: meta.title,
      page_number: meta.number,
      step_path: meta.path,
      current_step: nil,
      completed_steps: MapSet.new(),
      tour_steps: tour_steps,
      prev_page: prev_page,
      next_page: next_page
    )
    |> Phoenix.LiveView.attach_hook(:step_params, :handle_params, &handle_params_hook/3)
    |> Phoenix.LiveView.attach_hook(:step_events, :handle_event, &handle_event_hook/3)
  end

  defp handle_params_hook(params, _uri, socket) do
    completed_steps = parse_completed(params["completed"])
    {:halt, Phoenix.Component.assign(socket, :completed_steps, completed_steps)}
  end

  defp handle_event_hook("activate_step", %{"step" => step_id}, socket) do
    completed = MapSet.put(socket.assigns.completed_steps, step_id)

    {:halt,
     socket
     |> Phoenix.Component.assign(:current_step, step_id)
     |> Phoenix.LiveView.push_patch(
       to: build_path(socket.assigns.step_path, completed),
       replace: true
     )}
  end

  defp handle_event_hook("clear_tour", _params, socket) do
    {:halt, Phoenix.Component.assign(socket, :current_step, nil)}
  end

  defp handle_event_hook(_event, _params, socket) do
    {:cont, socket}
  end

  # Parses the `completed` query param into a MapSet of step IDs.
  defp parse_completed(nil), do: MapSet.new()
  defp parse_completed(""), do: MapSet.new()

  defp parse_completed(str) when is_binary(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end

  # Builds a step path with completed steps encoded as a query param.
  defp build_path(step_path, completed) do
    if MapSet.size(completed) > 0 do
      completed_str = completed |> MapSet.to_list() |> Enum.sort() |> Enum.join(",")
      step_path <> "?" <> URI.encode_query(%{"completed" => completed_str})
    else
      step_path
    end
  end
end
