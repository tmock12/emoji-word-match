defmodule WordMatchTest do
  use ExUnit.Case
  doctest WordMatch

  test "greets the world" do
    assert WordMatch.hello() == :world
  end
end
