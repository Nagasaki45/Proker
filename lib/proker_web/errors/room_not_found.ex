defmodule ProkerWeb.RoomNotFoundError do
  defexception [:message, plug_status: 404]
end
