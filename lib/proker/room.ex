defmodule Proker.Room do
  alias Proker.RoomConfig
  use GenServer

  # API

  def get_or_create(key) do
    case Registry.lookup(__MODULE__, key) do
      [{pid, nil}] -> {:ok, pid}
      _ -> start_link(key)
    end
  end

  def start_link(key) do
    name = via_tuple(key)
    GenServer.start_link(__MODULE__, key, name: name)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
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

  def configure(pid, config) do
    GenServer.cast(pid, {:configure, config})
  end

  # Callbacks

  @impl true
  def init(key) do
    {:ok, {key, %{}, %RoomConfig{}}}
  end

  @impl true
  def handle_call(:get_state, _from, {key, players, config}) do
    {
      :reply,
      {:ok, {prepare_players_to_client(players, config.anonymous_reveal), config}},
      {key, players, config}
    }
  end

  @impl true
  def handle_cast({:join, pid, name}, {key, players, config}) do
    players = put_in(players[pid], create_player(name))
    broadcast_msg(key, "#{name} joined")
    broadcast_players(key, players, config.anonymous_reveal)
    {:noreply, {key, players, config}}
  end

  @impl true
  def handle_cast({:leave, pid}, {key, players, config}) do
    {leaver, players} = pop_in(players[pid])

    if leaver do
      broadcast_msg(key, "#{leaver.name} left")
      broadcast_players(key, players, config.anonymous_reveal)
    end

    {:noreply, {key, players, config}}
  end

  @impl true
  def handle_cast({:vote, pid, value}, {key, players, config}) do
    players = put_in(players[pid].vote, value)
    broadcast_msg(key, "#{players[pid].name} voted")
    broadcast_players(key, players, config.anonymous_reveal)
    {:noreply, {key, players, config}}
  end

  @impl true
  def handle_cast(:reset_votes, {key, players, config}) do
    players = for {pid, p} <- players, into: %{}, do: {pid, create_player(p.name)}
    broadcast_msg(key, "Votes reset")
    broadcast_players(key, players, config.anonymous_reveal)
    {:noreply, {key, players, config}}
  end

  @impl true
  def handle_cast({:configure, config}, {key, players, _}) do
    broadcast_msg(key, "Configuration changed")
    broadcast_config(key, config)
    {:noreply, {key, players, config}}
  end

  # Internals

  defp via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  defp create_player(name) do
    %{name: name, vote: nil}
  end

  defp hide_vote(nil), do: nil
  defp hide_vote(_), do: "?"

  defp anonymise(player), do: %{player | name: "Anonymous"}

  defp prepare_players_to_client(players, anonymous_reveal) do
    players = Map.values(players)

    if Enum.all?(players, fn p -> p.vote end) do
      if anonymous_reveal do
        players
        |> Enum.shuffle()
        |> Enum.map(&anonymise/1)
      else
        players
      end
    else
      update_in(players, [Access.all(), :vote], &hide_vote/1)
    end
  end

  defp broadcast_msg(key, msg) do
    broadcast(key, {:msg, msg})
  end

  defp broadcast_players(key, players, anonymous_reveal) do
    broadcast(key, {:players, prepare_players_to_client(players, anonymous_reveal)})
  end

  defp broadcast_config(key, config) do
    broadcast(key, {:config, config})
  end

  defp broadcast(key, msg) do
    Phoenix.PubSub.broadcast(Proker.PubSub, key, msg)
  end
end
