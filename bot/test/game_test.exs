defmodule MikuBeats.GameTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, game} = MikuBeats.Game.start_link()
    bucket
  end

  test "creates an empty game", game do
    assert MikuBeats
  end
end
