defmodule ProkerWeb.RoomController do
  use ProkerWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:form_error, nil)
    |> render(:index)
  end

  @key_length 4
  @key_chars Enum.concat(?0..?9, ?A..?Z)

  def join(%{params: %{"key" => ""}} = conn, _params) do
    conn
    |> assign(:form_error, "Room key cannot be empty")
    |> render(:index)
  end

  def join(%{params: %{"key" => key}} = conn, _params) do
    redirect(conn, to: Routes.live_path(ProkerWeb.Endpoint, ProkerWeb.RoomLive, key))
  end

  def create(conn, _params) do
    key = for _ <- 1..@key_length, into: "", do: <<Enum.random(@key_chars)>>
    redirect(conn, to: Routes.live_path(ProkerWeb.Endpoint, ProkerWeb.RoomLive, key))
  end
end
