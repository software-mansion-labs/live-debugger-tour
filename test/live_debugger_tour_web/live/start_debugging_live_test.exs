defmodule LiveDebuggerTourWeb.Live.StartDebuggingLiveTest do
  use LiveDebuggerTourWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "page rendering" do
    test "renders the step title and progress", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/steps/start-debugging")
      assert has_element?(view, "#tour-progress")
      assert has_element?(view, "#tour-cards")
    end

    test "renders all three tour step cards", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/steps/start-debugging")
      assert has_element?(view, "#tour-step-1")
      assert has_element?(view, "#tour-step-2")
      assert has_element?(view, "#tour-step-3")
    end

    test "renders action buttons for each step", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/steps/start-debugging")
      assert has_element?(view, "#tour-btn-1")
      assert has_element?(view, "#tour-btn-2")
      assert has_element?(view, "#tour-btn-3")
    end
  end

  describe "tour interaction" do
    test "activating a step highlights the card", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/steps/start-debugging")

      view |> element("#tour-btn-1") |> render_click()
      assert has_element?(view, "#tour-step-1.ring-2")
    end

    test "activating a step marks it completed in progress", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/steps/start-debugging")

      view |> element("#tour-btn-1") |> render_click()
      assert has_element?(view, "#tour-progress .step-primary")
    end

    test "clear button appears when a step is active", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/steps/start-debugging")

      refute has_element?(view, "#clear-tour")
      view |> element("#tour-btn-1") |> render_click()
      assert has_element?(view, "#clear-tour")
    end

    test "clear button resets current step", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/steps/start-debugging")

      view |> element("#tour-btn-1") |> render_click()
      assert has_element?(view, "#clear-tour-btn")
      view |> element("#clear-tour-btn") |> render_click()
      refute has_element?(view, "#clear-tour")
    end
  end

  describe "navigation" do
    test "has a link back to the home page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/steps/start-debugging")
      assert has_element?(view, ~s|#step-navigation a[href="/"]|)
    end
  end

  describe "step discovery" do
    test "step is discoverable with correct metadata" do
      steps = LiveDebuggerTour.StepDiscovery.list_steps()
      step = Enum.find(steps, &(&1.title == "Start Debugging"))
      assert step != nil
      assert step.number == 1
      assert step.path == "/steps/start-debugging"
    end
  end
end
