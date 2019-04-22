defmodule WordMatch.PlayerTurns do
  defstruct played: [], remaining: []

  def rotate(%{remaining: [current | []], played: played}) do
    %{played: [], remaining: Enum.reverse([current | played])}
  end

  def rotate(%{remaining: [current | remaining], played: played}) do
    %{played: [current | played], remaining: remaining}
  end
end
