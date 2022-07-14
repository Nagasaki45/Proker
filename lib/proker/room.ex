defmodule Proker.Room do
  use GenServer

  # API

  def start_link(key) do
    name = Proker.RoomRegistry.via_tuple(key)
    GenServer.start_link(__MODULE__, key, name: name)
  end

  def get_players(pid) do
    GenServer.call(pid, :get_players)
  end

  def join(pid, name) do
    GenServer.cast(pid, {:join, self(), name})
  end

  def leave(pid) do
    GenServer.cast(pid, {:leave, self()})
  end

  def vote(pid, value) do
    GenServer.cast(pid, {:vote, self(), value})
  end

  def reset_votes(pid) do
    GenServer.cast(pid, :reset_votes)
  end

  # Callbacks

  @impl true
  def init(key) do
    {:ok, {key, %{}}}
  end

  @impl true
  def handle_call(:get_players, _from, {key, players}) do
    {:reply, {:ok, prepare_players_to_client(players)}, {key, players}}
  end

  @impl true
  def handle_cast({:join, pid, name}, {key, players}) do
    players = put_in(players[pid], create_player(name))
    broadcast_msg(key, "#{name} joined")
    broadcast_players(key, players)
    {:noreply, {key, players}}
  end

  @impl true
  def handle_cast({:leave, pid}, {key, players}) do
    {leaver, players} = pop_in(players[pid])

    if leaver do
      broadcast_msg(key, "#{leaver.name} left")
      broadcast_players(key, players)
    end

    {:noreply, {key, players}}
  end

  @impl true
  def handle_cast({:vote, pid, value}, {key, players}) do
    players = put_in(players[pid].vote, value)
    broadcast_msg(key, "#{players[pid].name} voted")
    broadcast_players(key, players)
    {:noreply, {key, players}}
  end

  @impl true
  def handle_cast(:reset_votes, {key, players}) do
    players = for {pid, p} <- players, into: %{}, do: {pid, create_player(p.name)}
    broadcast_msg(key, "Votes reset")
    broadcast_players(key, players)
    {:noreply, {key, players}}
  end

  # Internals

  defp create_player(name) do
    %{name: name, vote: nil}
  end

  defp hide_vote(x) when is_number(x), do: "?"
  defp hide_vote(_), do: nil

  defp prepare_players_to_client(players) do
    players = Map.values(players)

    if Enum.all?(players, fn p -> p.vote end) do
      players
    else
      update_in(players, [Access.all(), :vote], &hide_vote/1)
    end
  end

  defp broadcast_msg(key, msg) do
    Phoenix.PubSub.broadcast(Proker.PubSub, key, {:msg, msg})
  end

  defp broadcast_players(key, players) do
    Phoenix.PubSub.broadcast(
      Proker.PubSub,
      key,
      {:players, prepare_players_to_client(players)}
    )
  end
end
