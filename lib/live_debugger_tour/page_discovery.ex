defmodule LiveDebuggerTour.PageDiscovery do
  @moduledoc """
  Discovers all tutorial page modules at runtime.

  Scans all modules compiled for the `:live_debugger_tour` application
  and returns metadata from those that `use LiveDebuggerTour.Page`.
  Results are cached in `:persistent_term` after first call.
  """

  @cache_key {__MODULE__, :pages}

  @doc """
  Generates `live` route definitions for all discovered page modules.

  Intended to be called inside a router scope:

      scope "/" do
        pipe_through :browser
        LiveDebuggerTour.PageDiscovery.routes()
      end
  """
  defmacro routes do
    pages = LiveDebuggerTour.PageDiscovery.discover_pages_at_compile_time()

    live_files = Path.wildcard("lib/live_debugger_tour_web/live/**/*_live.ex")

    external_resources =
      for file <- live_files do
        abs_path = Path.expand(file)

        quote do
          @external_resource unquote(abs_path)
        end
      end

    route_defs =
      for page <- pages do
        quote do
          live unquote(page.path), unquote(page.module)
        end
      end

    {:__block__, [], external_resources ++ route_defs}
  end

  @doc false
  def discover_pages_at_compile_time do
    "lib/live_debugger_tour_web/live"
    |> Path.join("**/*_live.ex")
    |> Path.wildcard()
    |> Enum.flat_map(fn file ->
      with {:ok, module} <- extract_module(file),
           {:module, _} <- Code.ensure_compiled(module),
           true <- function_exported?(module, :__page_meta__, 0) do
        [module.__page_meta__()]
      else
        _ -> []
      end
    end)
    |> Enum.sort_by(& &1.number)
  end

  defp extract_module(file) do
    content = File.read!(file)

    case Regex.run(~r/defmodule\s+([\w.]+)/, content) do
      [_, module_str] -> {:ok, Module.concat([module_str])}
      _ -> :error
    end
  end

  @doc """
  Returns a sorted list of page metadata maps from all modules
  that use `LiveDebuggerTour.Page`.
  """
  def list_pages do
    case :persistent_term.get(@cache_key, nil) do
      nil ->
        pages = discover_pages()
        :persistent_term.put(@cache_key, pages)
        pages

      pages ->
        pages
    end
  end

  @doc """
  Returns `{prev_path, next_path}` for a given page number.
  Returns `"/"` as prev for page 1, and `nil` as next for the last page.
  """
  def page_navigation(page_number) do
    pages = list_pages()
    index = Enum.find_index(pages, &(&1.number == page_number))

    prev_page =
      cond do
        is_nil(index) -> "/"
        index == 0 -> "/"
        true -> Enum.at(pages, index - 1) |> Map.get(:path)
      end

    next_page =
      if index do
        pages
        |> Enum.at(index + 1)
        |> then(fn
          nil -> nil
          %{coming_soon: true} -> nil
          %{path: path} -> path
        end)
      end

    {prev_page, next_page}
  end

  @doc """
  Clears the cached page list. Useful during development when modules change.
  """
  def reset do
    :persistent_term.erase(@cache_key)
  end

  @doc false
  def after_compile_reset(_env, _bytecode) do
    reset()
  end

  defp discover_pages do
    :live_debugger_tour
    |> app_modules()
    |> Enum.filter(&page_module?/1)
    |> Enum.map(& &1.__page_meta__())
    |> Enum.sort_by(& &1[:number])
  end

  defp app_modules(app) do
    case :application.get_key(app, :modules) do
      {:ok, modules} -> modules
      :undefined -> []
    end
  end

  defp page_module?(mod) do
    Code.ensure_loaded?(mod) and function_exported?(mod, :__page_meta__, 0)
  end
end
