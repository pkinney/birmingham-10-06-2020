defmodule MyAppWeb.Login.LoginLive do
  use MyAppWeb, :live_view

  @impl true
  def mount(_, %{"current_user" => user}, socket) do
    {:ok, socket |> assign(%{delay: nil, current_user: user})}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="row">
      <div class="column column-60 column-offset-20" phx-hook="Login" id="login">
        <%= if @current_user == nil do %>
          <div class="phx-hero">
            <%= unless @delay do %>
              <h1>Log in</h1>
              <%= f = form_for :login, "#", [phx_submit: :login] %>
                <%= email_input f, :email, class: "input", placeholder: "Email" %>
                <%= password_input f, :password, class: "input", placeholder: "Password" %>
                <div class="clearfix">
                  <%= submit "Log in", class: "float-right" %>
                  </div>
              </form>
            <% else %>
              Logging you in...
              <br/>Please wait <%= @delay + 1 %> seconds
            <% end %>
          </div>
        <% else %>
          <h2>Welcome back, <%= @current_user %></h2>
          <button phx-click="logout">Logout</button>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("login", %{"login" => %{"email" => email, "password" => password}}, socket) do
    delay =
      case(Cachex.get(:backoff, email)) do
        {:ok, nil} -> 0
        {:ok, value} -> value
      end

    Process.send_after(self(), :delay, min(delay, 1) * 1000)
    {:noreply, socket |> assign(%{delay: delay, email: email, password: password})}
  end

  def handle_event("logout", _, socket) do
    {:noreply, socket |> push_event("token-destroyed", %{})}
  end

  @impl true
  def handle_info(:delay, %{assigns: %{delay: delay}} = socket) when delay > 0 do
    Process.send_after(self(), :delay, 1000)
    {:noreply, socket |> assign(:delay, delay - 1)}
  end

  def handle_info(:delay, %{assigns: %{email: email, password: password}} = socket) do
    case password do
      "12345" ->
        {:ok, token, _} = MyApp.Auth.Guardian.encode_and_sign(email)
        Cachex.del(:backoff, email)

        {:noreply,
         socket
         |> push_event("token-created", %{token: token})
         |> toast("Welcome back!")
         |> assign(%{delay: nil})}

      _ ->
        Cachex.get_and_update(:backoff, email, fn
          nil -> 1
          delay -> delay * 2
        end)

        {:noreply, socket |> toast("Invalid username or password.") |> assign(%{delay: nil})}
    end
  end
end
