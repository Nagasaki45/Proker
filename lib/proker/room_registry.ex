defmodule Proker.RoomRegistry do
  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  def get_or_create(key) do
    case Registry.lookup(__MODULE__, key) do
      [{pid, nil}] -> {:ok, pid}
      _ -> Proker.Room.start_link(key)
    end
  end

  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end
end
