defmodule ProkerWeb.RoomLive do
  use ProkerWeb, :live_view

  @impl true
  def mount(%{"key" => key}, _session, socket) do
    key = String.upcase(key)

    case Proker.RoomRegistry.lookup(key) do
      {:ok, pid} ->
        Phoenix.PubSub.subscribe(Proker.PubSub, key)
        do_mount(socket, key, pid)

      {:error, reason} ->
        raise ProkerWeb.RoomNotFoundError, message: reason
    end
  end

  def do_mount(socket, key, pid) do
    Process.flag(:trap_exit, true)
    {:ok, players} = Proker.Room.get_players(pid)

    socket
    |> assign(:key, key)
    |> assign(:pid, pid)
    |> assign(:players, players)
    |> assign(:request_name, true)
    |> tupled(:ok)
  end

  @impl true
  def handle_event("join", %{"name" => name}, socket) do
    Proker.Room.join(socket.assigns.pid, name)

    socket
    |> assign(:request_name, false)
    |> tupled(:noreply)
  end

  @impl true
  def handle_event("vote", %{"vote" => value}, socket) do
    Proker.Room.vote(socket.assigns.pid, String.to_integer(value))

    socket
    |> tupled(:noreply)
  end

  @impl true
  def handle_event("reset_votes", _params, socket) do
    Proker.Room.reset_votes(socket.assigns.pid)

    socket
    |> tupled(:noreply)
  end

  @impl true
  def handle_info({:players, players}, socket) do
    socket
    |> assign(:players, players)
    |> tupled(:noreply)
  end

  @impl true
  def handle_info({:msg, msg}, socket) do
    socket
    |> put_flash(:info, msg)
    |> tupled(:noreply)
  end

  @impl true
  def terminate(_reason, socket) do
    Proker.Room.leave(socket.assigns.pid)
  end

  defp tupled(second, first), do: {first, second}
end
