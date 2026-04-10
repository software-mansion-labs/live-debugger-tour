defmodule LiveDebuggerTour.StepDiscoveryTest do
  use ExUnit.Case, async: true

  alias LiveDebuggerTour.StepDiscovery

  test "list_steps/0 discovers modules using LiveDebuggerTour.Step" do
    steps = StepDiscovery.list_steps()

    assert Enum.any?(steps, fn step ->
             step.title == "Test Step" and step.number == 1 and step.path == "/steps/test"
           end)
  end

  test "list_steps/0 returns steps sorted by number" do
    steps = StepDiscovery.list_steps()
    numbers = Enum.map(steps, & &1.number)
    assert numbers == Enum.sort(numbers)
  end
end
