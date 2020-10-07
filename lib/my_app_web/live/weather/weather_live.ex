defmodule MyAppWeb.Weather.WeatherLive do
  use MyAppWeb, :live_view

  @url 'https://www.metaweather.com/api/location/2388929/'

  @impl true
  def mount(_, _, socket) do
    temp =
      cond do
        connected?(socket) -> fetch_temp()
        true -> nil
      end

    {:ok, socket |> assign(%{count: 0, temp: temp})}
  end

  defp fetch_temp() do
    {:ok, {{_, 200, _}, _, body}} = :httpc.request(:get, {@url, []}, [], [])
    %{"consolidated_weather" => [%{"the_temp" => temp} | _]} = body |> Jason.decode!()
    temp
  end

  @impl true
  def render(assigns) do
    ~L"""
      <div class="row">
        <div class="column">
          <div class="phx-hero">
          <h2>Today's Temperature</h2>
            <%= if @temp != nil do %>
              <h1 style="font-weight: bold;"><%= Float.round(@temp * 1.8 + 32, 1) %>°F <span style="font-size: 0.75em; font-weight: normal;">(<%= Float.round(@temp, 1) %>°C)</span></h1>
            <% else %>
              <h4>Loading...</h4>
            <% end %>
          </div>
        </div>
        <div class="column column-40 column-offset-10">
          <h2>Unreleated Interaction</h2>
          <h1 class="float-right"><%= @count %></h1>
          <div class="clear-fix">
            <button phx-click="increment">Click Me</button>
          </div>
        </div>
      </div>
    """
  end

  @impl true
  def handle_event("increment", _, socket) do
    {:noreply, socket |> assign(:count, socket.assigns.count + 1)}
  end
end
