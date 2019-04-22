defmodule PlayerTurnsTest do
  use ExUnit.Case, async: true
  alias WordMatch.{PlayerTurns}

  describe "advance" do
    test "it moves current player to played list" do
      turns =
        %PlayerTurns{remaining: ["player1", "player2"]}
        |> PlayerTurns.rotate()

      assert turns.played == ["player1"]
      assert turns.remaining == ["player2"]
    end

    test "with last remaining player, it resets" do
      turns =
        %PlayerTurns{remaining: ["player3"], played: ["player2", "player1"]}
        |> PlayerTurns.rotate()

      assert turns.played == []
      assert turns.remaining == ["player1", "player2", "player3"]
    end
  end
end
