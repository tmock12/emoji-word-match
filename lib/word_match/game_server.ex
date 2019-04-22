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

  def add_player(game_name, %{player_name: player_name}) do
    GenServer.call(via_tuple(game_name), {:add_player, player_name}, @server_timeout)
  end

  # Callbacks

  def init(game_options) do
    {:ok, WordMatch.Game.new(game_options), @server_timeout}
  end

  def handle_call({:guess, index}, _from, state) do
    case WordMatch.Game.guess(state, index) do
      %WordMatch.Game{} = game ->
        {:reply, public_view(game), game}

      {:error, error} ->
        {:reply, error, state}

      _ ->
        :nope
    end
  end

  def handle_call({:add_player, player_name}, _from, state) do
    case WordMatch.Game.add_player(state, player_name) do
      %WordMatch.Game{} = game ->
        {:reply, public_view(game), game}

      {:error, error} ->
        {:reply, error, state}
    end
  end

  defp public_view(%WordMatch.Game{} = game) do
    Map.take(game, ~w(board started)a)
  end
end
