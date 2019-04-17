defmodule WordMatch.GameServer do
  use GenServer

  @server_timeout :timer.hours(3)

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
    GenServer.call(via_tuple(game_name), {:guess, index}, @server_timeout)
  end

  # Callbacks

  def init(game_options) do
    {:ok, WordMatch.Game.new(game_options), @server_timeout}
  end

  def handle_call({:guess, index}, _from, state) do
    game = WordMatch.Game.guess(state, index)
    {:reply, public_view(game), game}
  end

  defp public_view(%WordMatch.Game{} = game) do
    Map.take(game, ~w(board)a)
  end
end
