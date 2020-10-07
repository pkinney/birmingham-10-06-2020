defmodule MyAppWeb.Weather.WeatherMintReadmeLive do
  use MyAppWeb, :live_view

  @host "www.gutenberg.org"
  @port 80
  @path "/cache/epub/10/pg10.txt"

  @impl true
  def mount(_, _, socket) do
    if connected?(socket) do
      {:ok, socket |> assign(%{temp: nil, count: 0, body: []}) |> start_request()}
    else
      {:ok, socket |> assign(%{temp: nil, count: 0, body: []})}
    end
  end

  defp start_request(socket) do
    {:ok, conn} = Mint.HTTP.connect(:http, @host, @port)
    {:ok, conn, request_ref} = Mint.HTTP.request(conn, "GET", @path, [], "")

    socket |> assign(%{conn: conn, request_ref: request_ref, body: []})
  end

  @impl true
  def render(assigns) do
    ~L"""
      <div class="row">
        <div class="column">
          <p style="font-size:3pt;">
            <%= @body |> Enum.join() |> String.replace("\r", " ") |>String.replace("\n", "") %>
          </p>
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

    Mint.HTTP.stream(conn, message)
    |> case do
      {:ok, conn, responses} ->
        Enum.reduce(responses, {orig_body, :incomplete}, fn mint_response, {body, _status} ->
          case mint_response do
            {:data, ^request_ref, data} -> {body ++ [data], :incomplete}
            {:done, ^request_ref} -> {body, :complete}
            {_, ^request_ref, _} -> {body, :incomplete}
          end
        end)
        |> case do
          {body, :complete} ->
            {:ok, closed_conn} = Mint.HTTP.close(conn)
            {:noreply, socket |> assign(%{conn: closed_conn, body: body})}

          {body, :incomplete} ->
            {:noreply, socket |> assign(%{conn: conn, body: body})}
        end

      {:error, conn, _, _} ->
        {:noreply, socket |> assign(%{conn: conn})}
    end
  end
end
