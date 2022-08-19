defmodule ProkerWeb.RoomLive do
  use ProkerWeb, :live_view

  @message_lifespan 5000

  @impl true
  def mount(%{"key" => key}, _session, socket) do
    key = String.upcase(key)
    Phoenix.PubSub.subscribe(Proker.PubSub, key)
    Process.flag(:trap_exit, true)

    {:ok, pid} = Proker.Room.get_or_create(key)
    {:ok, {players, config}} = Proker.Room.get_state(pid)

    socket
    |> assign(:key, key)
    |> assign(:pid, pid)
    |> assign(:players, players)
    |> assign(:config, config)
    |> assign(:request_name, true)
    |> assign(:messages, [])
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
    Proker.Room.vote(socket.assigns.pid, value)

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
  def handle_event("configure", params, socket) do
    config = Proker.RoomConfig.parse_config(params)
    Proker.Room.configure(socket.assigns.pid, config)

    socket
    |> assign(:config, config)
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
    Process.send_after(self(), :pop_message, @message_lifespan)

    socket
    |> assign(:messages, [msg | socket.assigns.messages])
    |> tupled(:noreply)
  end

  @impl true
  def handle_info(:pop_message, socket) do
    socket
    |> assign(:messages, List.delete_at(socket.assigns.messages, -1))
    |> tupled(:noreply)
  end

  @impl true
  def handle_info({:config, config}, socket) do
    socket
    |> assign(:config, config)
    |> tupled(:noreply)
  end

  @impl true
  def terminate(_reason, socket) do
    Proker.Room.leave(socket.assigns.pid)
  end

  defp tupled(second, first), do: {first, second}
end
