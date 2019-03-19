defmodule WordMatch.Card do
  @moduledoc """
  A container for the individual card
  """
  defstruct [:emoji, :word, matched_by: nil]

  def new(%{emoji: emoji, word: word}) do
    %__MODULE__{emoji: emoji, word: word}
  end
end
