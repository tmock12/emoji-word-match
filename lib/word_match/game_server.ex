defmodule WordMatch.GameServer do
  use GenServer

  # Client

  def start_link(game_name, game_options \\ %{}) do
    GenServer.start_link(
      __MODULE__,
      game_options,
      name: via_tuple(game_name)
    )
  end

  def via_tuple(game_name) do
    {:via, Registry, {WordMatch.GameRegistry, game_name}}
  end

  def guess(game_name, index) do
    GenServer.call(via_tuple(game_name), {:guess, index})
  end

  # Callbacks

  def init(game_options) do
    {:ok, WordMatch.Game.new(game_options)}
  end

  def handle_call({:guess, index}, _from, state) do
    game = WordMatch.Game.guess(state, index)
    {:reply, game, game}
  end
end
