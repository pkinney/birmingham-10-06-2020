defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Welcome!</h1>
    <p>Birmingham Elixir Meetup - October 6th, 2020</p>
    <ul>
      <li><%= live_redirect "Wizard", to: Routes.live_path(@socket, MyAppWeb.Wizard.WizardLive) %></li>
      <li><%= live_redirect "Login", to: Routes.live_path(@socket, MyAppWeb.Login.LoginLive) %></li>
      <li>
        Weather
        <ul>
          <li>
            <%= live_redirect "Mount", to: Routes.live_path(@socket, MyAppWeb.Weather.WeatherLive) %>
          </li>
          <li>
            <%= live_redirect "Async", to: Routes.live_path(@socket, MyAppWeb.Weather.WeatherAsyncLive) %>
          </li>
          <li>
            <%= live_redirect "Mint", to: Routes.live_path(@socket, MyAppWeb.Weather.WeatherMintLive) %>
          </li>
          <li>
            <%= live_redirect "Mint - Multipart", to: Routes.live_path(@socket, MyAppWeb.Weather.WeatherMintReadmeLive) %>
          </li>
        </ul>
      </li>
      <li><%= live_redirect "Toast", to: Routes.live_path(@socket, MyAppWeb.Toast.ParentLive) %></li>
    </ul>
    """
  end
end
