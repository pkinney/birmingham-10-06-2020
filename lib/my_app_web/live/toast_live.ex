defmodule MyAppWeb.ToastLive do
  use MyAppWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    if connected?(socket) do
      MyApp.ToastRegistry.register(socket)
    end

    {:ok, socket |> assign(:content, nil)}
  end

  @impl true
  def render(assigns) do
    ~L"""
      <div class='toast <%= if @content do "toast-shown" else "toast-hidden" end %>'><%= @content %></div>
    """
  end

  @impl true
  def handle_info({:toast, content}, socket) do
    Process.send_after(self(), :hide, 3000)

    {:noreply, socket |> assign(:content, content)}
  end

  def handle_info(:hide, socket) do
    {:noreply, socket |> assign(:content, nil)}
  end
end
