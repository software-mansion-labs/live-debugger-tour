defmodule LiveDebuggerTourWeb.PageController do
  use LiveDebuggerTourWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
