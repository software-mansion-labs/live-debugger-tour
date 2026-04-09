defmodule LiveDebuggerTourWeb.Live.StartDebuggingLiveTest do
  use LiveDebuggerTourWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "page rendering" do
    test "renders the page title and progress", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")
      assert has_element?(view, "#tour-progress")
      assert has_element?(view, "#tour-cards")
    end

    test "renders all three tour step cards", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")
      assert has_element?(view, "#tour-step-1")
      assert has_element?(view, "#tour-step-2")
      assert has_element?(view, "#tour-step-3")
    end

    test "renders action buttons for each step", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")
      assert has_element?(view, "#tour-btn-1")
      assert has_element?(view, "#tour-btn-2")
      assert has_element?(view, "#tour-btn-3")
    end
  end

  describe "tour interaction" do
    test "activating a step highlights the card", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")

      view |> element("#tour-btn-1") |> render_click()
      assert has_element?(view, "#tour-step-1.ring-2")
    end

    test "activating a step marks it completed in progress", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")

      view |> element("#tour-btn-1") |> render_click()
      assert has_element?(view, "#tour-progress .step-success")
    end

    test "clear button appears when a step is active", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")

      refute has_element?(view, "#clear-tour")
      view |> element("#tour-btn-1") |> render_click()
      assert has_element?(view, "#clear-tour")
    end

    test "clear button resets current step", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")

      view |> element("#tour-btn-1") |> render_click()
      assert has_element?(view, "#clear-tour-btn")
      view |> element("#clear-tour-btn") |> render_click()
      refute has_element?(view, "#clear-tour")
    end
  end

  describe "URL state persistence" do
    test "completed steps are restored from query params", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/pages/start-debugging?completed=1%2C2")
      assert has_element?(view, "#tour-step-1.ring-2")
      assert has_element?(view, "#tour-step-2.ring-2")
      refute has_element?(view, "#tour-step-3.ring-2")
    end

    test "activating a step updates the URL with completed param", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")

      view |> element("#tour-btn-1") |> render_click()
      assert_patched(view, "/pages/start-debugging?completed=1")
    end

    test "activating multiple steps accumulates in URL", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")

      view |> element("#tour-btn-1") |> render_click()
      view |> element("#tour-btn-3") |> render_click()
      assert_patched(view, "/pages/start-debugging?completed=1%2C3")
    end
  end

  describe "navigation" do
    test "has a link back to the home page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pages/start-debugging")
      assert has_element?(view, ~s|#page-navigation a[href="/"]|)
    end
  end

  describe "page discovery" do
    test "page is discoverable with correct metadata" do
      pages = LiveDebuggerTour.PageDiscovery.list_pages()
      page = Enum.find(pages, &(&1.title == "Start Debugging"))
      assert page != nil
      assert page.number == 1
      assert page.path == "/pages/start-debugging"
    end
  end
end
