defmodule LiveDebuggerTour.StepDiscoveryTest do
  use ExUnit.Case, async: true

  alias LiveDebuggerTour.StepDiscovery

  test "list_steps/0 returns an empty list when no steps are defined" do
    assert StepDiscovery.list_steps() == []
  end

  test "list_steps/0 returns a list" do
    assert is_list(StepDiscovery.list_steps())
  end
end
