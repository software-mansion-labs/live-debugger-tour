defmodule LiveDebuggerTourWeb.PageController do
  use LiveDebuggerTourWeb, :controller

  def home(conn, _params) do
    pages = LiveDebuggerTour.PageDiscovery.list_pages()
    render(conn, :home, pages: pages)
  end
end
