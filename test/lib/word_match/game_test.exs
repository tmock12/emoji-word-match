defmodule WordMatch.GameTest do
  use ExUnit.Case, async: true
  alias WordMatch.Game
  doctest Game

  describe "WordMatch.Game.guess/2" do
    setup do
      game = %Game{
        board: [%WordMatch.Card{}, %WordMatch.Card{}],
        guesses: [],
        values: [{"🐻", "Bear"}, {"🐻", "Bear"}]
      }

      {:ok, game: game}
    end

    test "adds emoji and word to board at index", %{game: game} do
      game = Game.guess(game, 0)

      assert %WordMatch.Card{emoji: "🐻", word: "Bear"} = Enum.at(game.board, 0)
    end

    test "adds index to guesses", %{game: game} do
      game = Game.guess(game, 0)
      assert [0] = game.guesses
      game = Game.guess(game, 1)
      assert [1, 0] = game.guesses
    end

    test "it does not add index when outside of board range", %{game: game} do
      game = Game.guess(game, 100)
      assert [] = game.guesses
    end
  end
end
