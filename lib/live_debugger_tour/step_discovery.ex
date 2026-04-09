defmodule LiveDebuggerTour.StepDiscovery do
  @moduledoc """
  Discovers all tutorial step modules at runtime.

  Scans all modules compiled for the `:live_debugger_tour` application
  and returns metadata from those that `use LiveDebuggerTour.Step`.
  Results are cached in `:persistent_term` after first call.
  """

  @cache_key {__MODULE__, :steps}

  @doc """
  Returns a sorted list of step metadata maps from all modules
  that use `LiveDebuggerTour.Step`.
  """
  def list_steps do
    case :persistent_term.get(@cache_key, nil) do
      nil ->
        steps = discover_steps()
        :persistent_term.put(@cache_key, steps)
        steps

      steps ->
        steps
    end
  end

  @doc """
  Returns `{prev_path, next_path}` for a given step number.
  Returns `"/"` as prev for step 1, and `nil` as next for the last step.
  """
  def step_navigation(step_number) do
    steps = list_steps()

    prev_page =
      if step_number == 1 do
        "/"
      else
        steps
        |> Enum.at(step_number - 2, %{})
        |> Map.get(:path)
      end

    next_page =
      steps
      |> Enum.at(step_number, %{})
      |> Map.get(:path)

    {prev_page, next_page}
  end

  @doc """
  Clears the cached step list. Useful during development when modules change.
  """
  def reset do
    :persistent_term.erase(@cache_key)
  end

  defp discover_steps do
    :live_debugger_tour
    |> app_modules()
    |> Enum.filter(&step_module?/1)
    |> Enum.map(& &1.__step_meta__())
    |> Enum.sort_by(& &1[:number])
  end

  defp app_modules(app) do
    case :application.get_key(app, :modules) do
      {:ok, modules} -> modules
      :undefined -> []
    end
  end

  defp step_module?(mod) do
    Code.ensure_loaded?(mod) and function_exported?(mod, :__step_meta__, 0)
  end
end
