defmodule MyAppWeb.Weather.WeatherMintLive do
  use MyAppWeb, :live_view

  @host "www.metaweather.com"
  @port 443
  @path "/api/location/2388929/"

  @impl true
  def mount(_, _, socket) do
    if connected?(socket) do
      {:ok, socket |> assign(%{temp: nil, count: 0}) |> start_request()}
    else
      {:ok, socket |> assign(%{temp: nil, count: 0})}
    end
  end

  defp start_request(socket) do
    {:ok, conn} = Mint.HTTP.connect(:https, @host, @port)
    {:ok, conn, request_ref} = Mint.HTTP.request(conn, "GET", @path, [], "")

    socket |> assign(%{conn: conn, request_ref: request_ref, body: []})
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

  @impl true
  def handle_info(message, socket) do
    %{
      conn: conn,
      request_ref: request_ref,
      body: orig_body
    } = socket.assigns

    {:ok, conn, responses} = Mint.HTTP.stream(conn, message)

    Enum.reduce(responses, {orig_body, :incomplete}, fn mint_response, {body, _status} ->
      case mint_response do
        {:data, ^request_ref, data} -> {[data | body], :incomplete}
        {:done, ^request_ref} -> {Enum.reverse(body), :complete}
        {_, ^request_ref, _} -> {body, :incomplete}
      end
    end)
    |> case do
      {body, :complete} ->
        %{"consolidated_weather" => [%{"the_temp" => temp} | _]} = body |> Jason.decode!()
        {:ok, closed_conn} = Mint.HTTP.close(conn)
        {:noreply, socket |> assign(%{temp: temp, conn: closed_conn, body: body})}

      {body, :incomplete} ->
        {:noreply, socket |> assign(%{conn: conn, body: body})}
    end
  end
end
