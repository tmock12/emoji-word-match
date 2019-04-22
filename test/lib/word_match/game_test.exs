defmodule WordMatch.GameTest do
  use ExUnit.Case, async: true
  alias WordMatch.{Game, Player}
  doctest Game

  describe "start_game/1" do
    setup do
      game = Game.new()
      {:ok, game: game}
    end

    test "returns an error if already started", %{game: game} do
      game = %{game | started: true}
      assert {:error, "already started"} = Game.start_game(game)
    end

    test "returns an error if 0 players", %{game: game} do
      game = %{game | players: []}
      assert {:error, "must have at least 1 player"} = Game.start_game(game)
    end

    test "starts game and sets player turns", %{game: game} do
      player1 = %Player{name: "Taylor"}
      player2 = %Player{name: "Mia"}

      game =
        game
        |> Map.put(:players, [player2, player1])

      assert %{started: true, player_turns: player_turns} = Game.start_game(game)
      assert [player1, player2] = player_turns.remaining
    end
  end

  describe "WordMatch.Game.guess/2" do
    setup do
      game = %Game{
        board: [%WordMatch.Card{}, %WordMatch.Card{}],
        guesses: [],
        values: [{"🐻", "Bear"}, {"🐻", "Bear"}],
        started: true
      }

      {:ok, game: game}
    end

    test "error if game unstarted", %{game: game} do
      game = %{game | started: false}
      assert Game.guess(game, 0) == {:error, "game must be started"}
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
