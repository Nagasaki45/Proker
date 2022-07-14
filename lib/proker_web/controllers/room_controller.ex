defmodule ProkerWeb.RoomController do
  use ProkerWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  @key_length 4

  def create(conn, _params) do
    chars = Enum.concat(?0..?9, ?A..?Z)
    key = for _ <- 1..@key_length, into: "", do: <<Enum.random(chars)>>
    {:ok, _pid} = Proker.Room.start_link(key)
    redirect(conn, to: Routes.live_path(ProkerWeb.Endpoint, ProkerWeb.RoomLive, key))
  end
end
