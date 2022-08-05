defmodule Proker.RoomConfig do
  defstruct anonymous_reveal: false, vote_values: [1, 2, 3, 5, 8, 13]

  def parse_config(%{"anonymous_reveal" => "on"}), do: %__MODULE__{anonymous_reveal: true}
  def parse_config(_), do: %__MODULE__{}
end
