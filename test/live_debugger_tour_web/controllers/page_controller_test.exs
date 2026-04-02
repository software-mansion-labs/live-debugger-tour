defmodule LiveDebuggerTourWeb.PageControllerTest do
  use LiveDebuggerTourWeb.ConnCase

  test "GET / renders welcome page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Welcome to LiveDebugger Tour"
  end

  test "GET / shows empty state when no steps exist", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "No tutorial steps available yet"
  end
end
