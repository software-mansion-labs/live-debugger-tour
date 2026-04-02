defmodule LiveDebuggerTourWeb.PageControllerTest do
  use LiveDebuggerTourWeb.ConnCase

  test "GET / renders welcome page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Welcome to LiveDebugger Tour"
  end

  test "GET / lists discovered tutorial steps", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Test Step"
  end
end
