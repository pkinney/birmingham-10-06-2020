defmodule MyApp.ToastRegistry do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    :ets.new(:toast_for_root, [:named_table])
    :ets.new(:root_for_toast, [:private, :named_table])
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:register, socket, toast_pid}, state) do
    true = :ets.insert(:toast_for_root, {socket.root_pid, toast_pid})
    true = :ets.insert(:root_for_toast, {toast_pid, socket.root_pid})
    Process.monitor(toast_pid)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, _, toast_pid, _}, state) do
    case :ets.lookup(:root_for_toast, toast_pid) do
      [{_, root_pid}] ->
        :ets.delete_object(:toast_for_root, {root_pid, toast_pid})
        :ets.delete_object(:root_for_toast, {toast_pid, root_pid})

      [] ->
        nil
    end

    {:noreply, state}
  end

  def register(socket) do
    GenServer.cast(__MODULE__, {:register, socket, self()})
  end

  def toast(socket, message) do
    case :ets.lookup(:toast_for_root, socket.root_pid) do
      [{_, toast_pid}] -> Process.send(toast_pid, {:toast, message}, [])
      [] -> nil
    end

    socket
  end
end
