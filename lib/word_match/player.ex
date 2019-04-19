defmodule WordMatch.Player do
  @moduledoc """
  A container for a player
  """
  defstruct [:name]

  def new(%{name: name}) do
    %__MODULE__{name: name}
  end
end
