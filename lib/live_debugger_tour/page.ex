defmodule LiveDebuggerTour.Page do
  @moduledoc """
  Macro for declaring a LiveView tutorial page.

  Provides page metadata for auto-discovery, shared mount logic via
  `tour_page_assigns/2`, and lifecycle hooks for tour interaction.

  Completed steps are persisted in the URL query string (`?completed=1,2,3`)
  so progress survives page refresh.

  ## Usage

      defmodule LiveDebuggerTourWeb.Live.HelloWorldLive do
        use LiveDebuggerTourWeb, :live_view
        use LiveDebuggerTour.Page,
          number: 1,
          title: "Hello World",
          description: "Your first LiveView"

        @tour_steps [...]

        @impl true
        def mount(_params, _session, socket) do
          {:ok, tour_page_assigns(socket, @tour_steps, redirect_url: "..."}
        end

        @impl true
        def render(assigns) do
          ~H"..."
        end
      end
  """

  @required_keys [:number, :title, :description]

  defmacro __using__(opts) do
    missing = @required_keys -- Keyword.keys(opts)

    if missing != [] do
      raise ArgumentError, "missing required Page keys: #{inspect(missing)}"
    end

    title = Keyword.fetch!(opts, :title)
    path = "/pages/#{LiveDebuggerTour.Page.slugify(title)}"

    quote do
      @after_compile {LiveDebuggerTour.PageDiscovery, :after_compile_reset}

      def __page_meta__ do
        unquote(opts)
        |> Map.new()
        |> Map.put(:path, unquote(path))
        |> Map.put(:module, __MODULE__)
      end

      @doc false
      def tour_page_assigns(socket, tour_steps, opts \\ []) do
        meta = __page_meta__()

        LiveDebuggerTour.Page.tour_page_assigns(socket, tour_steps, meta, opts)
      end
    end
  end

  @doc "Converts a title string to a URL-safe slug."
  def slugify(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/u, "")
    |> String.replace(~r/[\s_]+/, "-")
    |> String.trim("-")
  end

  def tour_page_assigns(socket, tour_steps, meta, opts \\ []) do
    skip_redirect = Keyword.get(opts, :skip_redirect, false)

    if Phoenix.LiveView.connected?(socket) and not skip_redirect do
      url =
        Keyword.get_lazy(opts, :redirect_url, fn ->
          LiveDebugger.App.Web.Helpers.Routes.debugger_node_inspector(self())
        end)

      LiveDebugger.Tour.redirect(url)
    end

    {prev_page, next_page} = LiveDebuggerTour.PageDiscovery.page_navigation(meta.number)

    socket
    |> Phoenix.Component.assign(
      page_title: meta.title,
      page_number: meta.number,
      page_path: meta.path,
      current_step: nil,
      completed_steps: MapSet.new(),
      tour_steps: tour_steps,
      prev_page: prev_page,
      next_page: next_page
    )
    |> Phoenix.LiveView.attach_hook(:page_params, :handle_params, &handle_params_hook/3)
    |> Phoenix.LiveView.attach_hook(:page_events, :handle_event, &handle_event_hook/3)
  end

  @doc "Parses the `completed` query param into a MapSet of step IDs."
  def parse_completed(nil), do: MapSet.new()
  def parse_completed(""), do: MapSet.new()

  def parse_completed(str) when is_binary(str) do
    str
    |> String.split(",")
    |> Enum.flat_map(fn s ->
      case Integer.parse(s) do
        {n, ""} -> [n]
        _ -> []
      end
    end)
    |> MapSet.new()
  end

  defp handle_params_hook(params, _uri, socket) do
    completed_steps = parse_completed(params["completed"])
    {:halt, Phoenix.Component.assign(socket, :completed_steps, completed_steps)}
  end

  defp handle_event_hook("activate_step", %{"step" => step_id}, socket) do
    completed = MapSet.put(socket.assigns.completed_steps, step_id)

    {:halt, assign_completed(socket, step_id, completed)}
  end

  defp handle_event_hook("deactivate_step", %{"step" => step_id}, socket) do
    completed = MapSet.delete(socket.assigns.completed_steps, step_id)

    {:halt, assign_completed(socket, nil, completed)}
  end

  defp handle_event_hook("clear_tour", _params, socket) do
    {:halt, Phoenix.Component.assign(socket, :current_step, nil)}
  end

  defp handle_event_hook(_event, _params, socket) do
    {:cont, socket}
  end

  defp assign_completed(socket, current_step, completed) do
    socket
    |> Phoenix.Component.assign(:current_step, current_step)
    |> Phoenix.LiveView.push_patch(
      to: build_path(socket.assigns.page_path, completed),
      replace: true
    )
  end

  # Builds a page path with completed steps encoded as a query param.
  defp build_path(page_path, completed) do
    if MapSet.size(completed) > 0 do
      completed_str = completed |> MapSet.to_list() |> Enum.sort() |> Enum.join(",")
      page_path <> "?" <> URI.encode_query(%{"completed" => completed_str})
    else
      page_path
    end
  end
end
