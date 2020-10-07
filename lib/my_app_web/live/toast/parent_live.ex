defmodule MyAppWeb.Toast.ParentLive do
  use MyAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Toast Demo</h1>
    <%= live_render @socket, MyAppWeb.Toast.ChildLive, id: "child" %>
    """
  end
end
