defmodule LiveDebuggerTour.Step do
  @moduledoc """
  Macro for declaring a LiveView tutorial step.

  Provides step metadata for auto-discovery, shared mount logic via
  `step_assigns/2`, URL-persisted progress via `handle_params`, and
  default `handle_event` callbacks for tour interaction.

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
          {:ok, step_assigns(socket, @tour_steps)}
        end

        @impl true
        def render(assigns) do
          ~H"..."
        end

        # handle_params, handle_event for "activate_step" and "clear_tour"
        # are injected automatically. Override with defoverridable if needed.
      end
  """

  @required_keys [:number, :title, :description, :path]

  @doc """
  Parses the `completed` query param into a MapSet of step IDs.
  """
  def parse_completed(nil), do: MapSet.new()
  def parse_completed(""), do: MapSet.new()

  def parse_completed(str) when is_binary(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end

  @doc """
  Builds a step path with completed steps encoded as a query param.
  """
  def build_path(step_path, completed) do
    if MapSet.size(completed) > 0 do
      completed_str = completed |> MapSet.to_list() |> Enum.sort() |> Enum.join(",")
      step_path <> "?" <> URI.encode_query(%{"completed" => completed_str})
    else
      step_path
    end
  end

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

        if Phoenix.LiveView.connected?(socket) do
          url =
            Keyword.get_lazy(opts, :redirect_url, fn ->
              LiveDebugger.App.Web.Helpers.Routes.debugger_node_inspector(self())
            end)

          LiveDebugger.Tour.redirect(url)
        end

        {prev_page, next_page} = LiveDebuggerTour.StepDiscovery.step_navigation(meta.number)

        Phoenix.Component.assign(socket,
          page_title: meta.title,
          page_number: meta.number,
          step_path: meta.path,
          current_step: nil,
          completed_steps: MapSet.new(),
          tour_steps: tour_steps,
          prev_page: prev_page,
          next_page: next_page
        )
      end

      @impl true
      def handle_params(params, _uri, socket) do
        completed_steps = LiveDebuggerTour.Step.parse_completed(params["completed"])
        {:noreply, Phoenix.Component.assign(socket, :completed_steps, completed_steps)}
      end

      @impl true
      def handle_event("activate_step", %{"step" => step_id}, socket) do
        completed = MapSet.put(socket.assigns.completed_steps, step_id)

        {:noreply,
         socket
         |> Phoenix.Component.assign(:current_step, step_id)
         |> Phoenix.LiveView.push_patch(
           to: LiveDebuggerTour.Step.build_path(socket.assigns.step_path, completed),
           replace: true
         )}
      end

      def handle_event("clear_tour", _params, socket) do
        {:noreply, Phoenix.Component.assign(socket, :current_step, nil)}
      end

      defoverridable handle_params: 3, handle_event: 3
    end
  end
end
