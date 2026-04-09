defmodule LiveDebuggerTour.StepDiscoveryTest do
  use ExUnit.Case, async: true

  alias LiveDebuggerTour.StepDiscovery

  setup do
    StepDiscovery.reset()
    :ok
  end

  test "list_steps/0 discovers modules using LiveDebuggerTour.Step" do
    steps = StepDiscovery.list_steps()

    assert Enum.any?(steps, fn step ->
             step.title == "Start Debugging" and step.number == 1 and
               step.path == "/steps/start-debugging"
           end)
  end

  test "list_steps/0 returns steps sorted by number" do
    steps = StepDiscovery.list_steps()
    numbers = Enum.map(steps, & &1.number)
    assert numbers == Enum.sort(numbers)
  end

  test "step_navigation/1 returns prev and next paths" do
    {prev, next} = StepDiscovery.step_navigation(1)
    assert prev == "/"
    assert is_binary(next) or is_nil(next)
  end

  test "step_navigation/1 returns home as prev for step 1" do
    {prev, _next} = StepDiscovery.step_navigation(1)
    assert prev == "/"
  end
end
