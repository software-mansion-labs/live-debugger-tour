defmodule LiveDebuggerTour.Step do
  @moduledoc """
  Macro for declaring a LiveView tutorial step.

  ## Usage

      defmodule LiveDebuggerTourWeb.Steps.HelloWorldLive do
        use LiveDebuggerTourWeb, :live_view
        use LiveDebuggerTour.Step,
          number: 1,
          title: "Hello World",
          description: "Your first LiveView",
          path: "/steps/hello-world"

        # ... LiveView implementation
      end
  """

  defmacro __using__(opts) do
    quote do
      def __step_meta__ do
        Map.new(unquote(opts))
      end
    end
  end
end
