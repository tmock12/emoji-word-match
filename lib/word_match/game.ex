defmodule WordMatch.Game do
  @moduledoc """
  Container for a game or emoji word match.
  """

  defstruct values: [], board: [], guesses: [], players: [], player_rotation: []

  @game_defaults %{
    pairs: 6,
    emojis: WordMatch.Emojis.read(),
    players: []
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
      emojis: emojis,
      players: players
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

    %__MODULE__{values: values, board: board, players: players}
  end

  @doc """
  Take a guess at an index on a `%WordMatch.Game{}`
  """
  def guess(%__MODULE__{board: board} = game, index) when index >= length(board) do
    game
  end

  def guess(%__MODULE__{guesses: guesses} = game, index) when length(guesses) < 2 do
    case already_guessed?(game, index) do
      true -> game
      false -> update_board_guess(game, index)
    end
  end

  def guess(%__MODULE__{guesses: guesses} = game, index) when length(guesses) >= 2 do
    game
    |> mark_matched_or_empty
    |> clear_guesses
    |> advance_player
    |> guess(index)
  end

  def add_player(%__MODULE__{players: players, player_rotation: player_rotation} = game, name) do
    new_player = WordMatch.Player.new(%{name: name})
    %{game | players: players ++ [new_player], player_rotation: player_rotation ++ [new_player]}
  end

  defp mark_matched_or_empty(%{board: board, guesses: [guess1, guess2]} = game) do
    value1 = board |> Enum.at(guess1)
    value2 = board |> Enum.at(guess2)

    match_or_empty =
      case value1 == value2 do
        true -> %{value1 | matched_by: :player_1}
        false -> %WordMatch.Card{}
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

  def advance_player(%{player_rotation: player_rotation, players: players} = game) do
    new_player_rotation =
      case player_rotation do
        [_currentPlayer | []] ->
          players

        [_currentPlayer | remainingPlayers] ->
          remainingPlayers
      end

    %{game | player_rotation: new_player_rotation}
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
