defmodule ProkerWeb.RoomController do
  use ProkerWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def create(conn, _params) do
    {:ok, key} = Proker.Room.start_link()
    redirect(conn, to: Routes.live_path(ProkerWeb.Endpoint, ProkerWeb.RoomLive, key))
  end
end
