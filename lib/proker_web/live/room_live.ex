defmodule ProkerWeb.RoomLive do
  use ProkerWeb, :live_view
  import Proker.Utils
  import ProkerWeb.Components

  @notification_lifespan 5000

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
    |> assign(:user_joined, false)
    |> assign(:notifications, [])
    |> tupled(:ok)
  end

  @impl true
  def handle_event("join", %{"name" => name}, socket) do
    Proker.Room.join(socket.assigns.pid, name)

    socket
    |> assign(:user_joined, true)
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
    Process.send_after(self(), :pop_notification, @notification_lifespan)

    socket
    |> assign(:notifications, [msg | socket.assigns.notifications])
    |> tupled(:noreply)
  end

  @impl true
  def handle_info(:pop_notification, socket) do
    socket
    |> assign(:notifications, List.delete_at(socket.assigns.notifications, -1))
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
end
