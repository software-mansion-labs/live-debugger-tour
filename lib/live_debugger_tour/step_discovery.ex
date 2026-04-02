defmodule LiveDebuggerTour.StepDiscovery do
  @moduledoc """
  Discovers all tutorial step modules at runtime.

  Scans all modules compiled for the `:live_debugger_tour` application
  and returns metadata from those that `use LiveDebuggerTour.Step`.
  """

  @doc """
  Returns a sorted list of step metadata maps from all modules
  that use `LiveDebuggerTour.Step`.
  """
  def list_steps do
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
