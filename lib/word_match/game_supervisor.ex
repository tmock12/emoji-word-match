defmodule WordMatch.GameSupervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(name, options \\ %{}) do
    child_spec = %{
      id: WordMatch.GameServer,
      start: {WordMatch.GameServer, :start_link, [name, options]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
