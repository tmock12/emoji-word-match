defmodule WordMatch.GameServerTest do
  use ExUnit.Case, async: true
  alias WordMatch.{GameServer, Game}

  test "game names are registered unique" do
    name = "Game A"

    assert {:ok, _pid} = GameServer.start_link(name)
    assert {:error, {:already_started, _pid}} = GameServer.start_link(name)
  end

  describe "callbacks" do
    setup do
      {:ok, state: Game.new()}
    end

    test "guesses a word at given index", %{state: state} do
      index = Enum.random(1..5)
      {:reply, _public_view, game} = GameServer.handle_call({:guess, index}, nil, state)
      marked_card = Enum.at(game.board, index)
      refute marked_card.word == nil
      refute marked_card.emoji == nil
    end

    test "returns a simplified public view", %{state: state} do
      index = Enum.random(1..5)
      {:reply, public_view, game} = GameServer.handle_call({:guess, index}, nil, state)
      assert public_view == %{board: game.board}
    end
  end
end
