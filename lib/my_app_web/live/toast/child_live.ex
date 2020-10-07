defmodule MyAppWeb.Toast.ChildLive do
  use MyAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <button phx-click="make-toast">Make Toast</button>
    """
  end

  @impl true
  def handle_event("make-toast", _, socket) do
    {:noreply, socket |> toast("Hello!")}
  end
end
