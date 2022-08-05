defmodule Proker.RoomConfig do
  @default_voting_buttons ~w(1 2 3 5 8 13)
  defstruct anonymous_reveal: false, voting_buttons: @default_voting_buttons

  def parse_config(params) do
    %__MODULE__{
      anonymous_reveal: parse_anonymous_reveal(params["anonymous_reveal"]),
      voting_buttons: parse_voting_buttons(params["voting_buttons"])
    }
  end

  defp parse_anonymous_reveal("on"), do: true
  defp parse_anonymous_reveal(_), do: false

  defp parse_voting_buttons(nil), do: @default_voting_buttons

  defp parse_voting_buttons(voting_buttons) do
    voting_buttons
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end
end
