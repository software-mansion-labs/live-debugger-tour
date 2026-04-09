defmodule LiveDebuggerTour.PageDiscoveryTest do
  use ExUnit.Case, async: true

  alias LiveDebuggerTour.PageDiscovery

  setup do
    PageDiscovery.reset()
    :ok
  end

  test "list_pages/0 discovers modules using LiveDebuggerTour.Page" do
    pages = PageDiscovery.list_pages()

    assert Enum.any?(pages, fn page ->
             page.title == "Start Debugging" and page.number == 1 and
               page.path == "/pages/start-debugging"
           end)
  end

  test "list_pages/0 returns pages sorted by number" do
    pages = PageDiscovery.list_pages()
    numbers = Enum.map(pages, & &1.number)
    assert numbers == Enum.sort(numbers)
  end

  test "page_navigation/1 returns prev and next paths" do
    {prev, next} = PageDiscovery.page_navigation(1)
    assert prev == "/"
    assert is_binary(next) or is_nil(next)
  end

  test "page_navigation/1 returns home as prev for page 1" do
    {prev, _next} = PageDiscovery.page_navigation(1)
    assert prev == "/"
  end
end
