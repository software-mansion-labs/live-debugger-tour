defmodule LiveDebuggerTour.PageDiscovery do
  @moduledoc """
  Discovers all tutorial page modules at runtime.

  Scans all modules compiled for the `:live_debugger_tour` application
  and returns metadata from those that `use LiveDebuggerTour.Page`.
  Results are cached in `:persistent_term` after first call.
  """

  @cache_key {__MODULE__, :pages}

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

    prev_page =
      if page_number == 1 do
        "/"
      else
        pages
        |> Enum.at(page_number - 2, %{})
        |> Map.get(:path)
      end

    next_page =
      pages
      |> Enum.at(page_number, %{})
      |> Map.get(:path)

    {prev_page, next_page}
  end

  @doc """
  Clears the cached page list. Useful during development when modules change.
  """
  def reset do
    :persistent_term.erase(@cache_key)
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
