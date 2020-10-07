defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_my_app_key",
    signing_salt: "L/2L0gNy"
  ]

  socket "/socket", MyAppWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :my_app,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :my_app
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug :maybe_load_current_user
  plug MyAppWeb.Router

  def maybe_load_current_user(conn, _opts) do
    with {_, cookies} <- Enum.find(conn.req_headers, fn {key, _} -> key == "cookie" end),
         [session_line | _] <-
           cookies
           |> String.split("; ")
           |> Enum.filter(fn cookie -> String.starts_with?(cookie, "session=") end),
         [_, session] <- String.split(session_line, "=", parts: 2),
         {:ok, %{"sub" => email}} <-
           MyApp.Auth.Guardian.decode_and_verify(session) do
      conn |> fetch_session() |> put_session("current_user", email)
    else
      _ -> conn |> fetch_session() |> put_session("current_user", nil)
    end
  end
end
