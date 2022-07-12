defmodule ProkerWeb.PageController do
  use ProkerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
