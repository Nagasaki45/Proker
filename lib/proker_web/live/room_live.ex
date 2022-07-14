defmodule ProkerWeb.RoomLive do
  use ProkerWeb, :live_view

  @impl true
  def mount(%{"key" => key}, _session, socket) do
    Process.flag(:trap_exit, true)
    Phoenix.PubSub.subscribe(Proker.PubSub, key)
    {:ok, players} = Proker.Room.get_players(key)

    socket
    |> assign(:key, key)
    |> assign(:players, players)
    |> assign(:request_name, true)
    |> tupled(:ok)
  end

  @impl true
  def handle_event("join", %{"name" => name}, socket) do
    Proker.Room.join(socket.assigns.key, name)

    socket
    |> assign(:request_name, false)
    |> tupled(:noreply)
  end

  @impl true
  def handle_event("vote", %{"vote" => value}, socket) do
    Proker.Room.vote(socket.assigns.key, value)

    socket
    |> tupled(:noreply)
  end

  @impl true
  def handle_event("reset_votes", _params, socket) do
    Proker.Room.reset_votes(socket.assigns.key)

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
    Proker.Room.leave(socket.assigns.key)
  end

  defp tupled(second, first), do: {first, second}
end
