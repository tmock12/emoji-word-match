defmodule WordMatch.Game do
  @moduledoc """
  Container for a game or emoji word match.
  """

  defstruct values: [], board: [], guesses: [], players: [], player_turns: [], started: false

  @game_defaults %{
    pairs: 6,
    emojis: WordMatch.Emojis.read()
  }

  @doc """
  Creates a new game with guesses, board and values.

  Options:

  * `pairs`: How many pairs or emojis you want
  * `emojies`: A list of tuples of emojis and words to use

  ## Examples

      iex> WordMatch.Game.new()
      ...> |> case do
      ...>   %WordMatch.Game{
      ...>     board: [%WordMatch.Card{} | _cards],
      ...>     guesses: [],
      ...>     values: [{_emoji, _word} | _emojs]
      ...>  } -> true
      ...> end
      true

      iex> game = WordMatch.Game.new()
      ...> game.guesses
      []
      iex> length(game.board)
      12
      iex> length(game.values)
      12

      iex> game = WordMatch.Game.new(%{pairs: 1, emojis: [{"📦", "Box"}]})
      ...> game.guesses
      []
      iex> game.board
      [%WordMatch.Card{}, %WordMatch.Card{}]
      iex> game.values
      [{"📦", "Box"}, {"📦", "Box"}]

      ---
  """
  def new(options \\ %{}) do
    %{
      pairs: pairs,
      emojis: emojis
    } = Map.merge(@game_defaults, options)

    values =
      emojis
      |> Enum.take_random(pairs)
      |> List.duplicate(2)
      |> List.flatten()
      |> Enum.shuffle()

    board =
      %WordMatch.Card{}
      |> List.duplicate(pairs * 2)

    %__MODULE__{values: values, board: board}
  end

  @doc """
  Start a game and lock in player turns
  """

  def start_game(%__MODULE__{started: true}), do: {:error, "already started"}
  def start_game(%__MODULE__{players: []}), do: {:error, "must have at least 1 player"}

  def start_game(%__MODULE__{started: false, players: players} = game) do
    game
    |> Map.put(:started, true)
    |> Map.put(:player_turns, %WordMatch.PlayerTurns{remaining: Enum.reverse(players)})
  end

  @doc """
  Take a guess at an index on a `%WordMatch.Game{}`
  """
  def guess(%__MODULE__{started: false}, _index) do
    {:error, "game must be started"}
  end

  def guess(%__MODULE__{board: board} = game, index) when index >= length(board) do
    game
  end

  def guess(%__MODULE__{guesses: guesses} = game, index) when length(guesses) >= 2 do
    game
    |> mark_matched_or_empty
    |> clear_guesses
    |> advance_player
    |> guess(index)
  end

  def guess(%__MODULE__{} = game, index) do
    case already_guessed?(game, index) do
      true -> game
      false -> update_board_guess(game, index)
    end
  end

  def add_player(%__MODULE__{started: true}, _name), do: :error

  def add_player(%__MODULE__{players: players} = game, player_name) do
    %{game | players: [player_name | players]}
  end

  defp mark_matched_or_empty(%{board: board, guesses: [guess1, guess2]} = game) do
    value1 = board |> Enum.at(guess1)
    value2 = board |> Enum.at(guess2)

    match_or_empty =
      case value1 == value2 do
        true ->
          [current_player | _remaining] = game.player_turns.remaining
          %{value1 | matched_by: current_player}

        false ->
          %WordMatch.Card{}
      end

    board =
      game.board
      |> List.replace_at(guess1, match_or_empty)
      |> List.replace_at(guess2, match_or_empty)

    %{game | board: board}
  end

  defp clear_guesses(game) do
    %{game | guesses: []}
  end

  defp advance_player(%{player_turns: player_turns} = game) do
    %{game | player_turns: WordMatch.PlayerTurns.rotate(player_turns)}
  end

  defp update_board_guess(game, index) do
    {emoji, word} =
      game.values
      |> Enum.at(index)

    new_board =
      List.replace_at(
        game.board,
        index,
        %WordMatch.Card{emoji: emoji, word: word}
      )

    %{game | board: new_board, guesses: [index | game.guesses]}
  end

  defp already_guessed?(game, index) do
    !!Enum.at(game.board, index).word
  end
end
