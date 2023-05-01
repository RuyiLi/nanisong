defmodule MikuBeats.Game do
  @doc """
    A game instance.
    query - curr, list
    mutate - next, clear, create
  """

  use Agent

  @initial_done [
    song: false,
    artist: false,
    anime: false,
  ]

  def start_link(opts) do
    Agent.start_link fn -> %{
      curr: nil,
      list: nil,
      state: :inactive,
      done: @initial_done,
      channel_id: nil,
      options: opts,
    } end
  end

  def done?(game) do
    Agent.get game, fn state ->
      state.done
      |> Keyword.values
      |> Enum.all?
    end
  end

  def curr(game) do
    Agent.get game, &Map.get(&1, :curr)
  end

  def list(game) do
    Agent.get game, &Map.get(&1, :list)
  end

  def channel_id(game) do
    Agent.get game, &Map.get(&1, :channel_id)
  end

  def get_setting(game, key, default) do
    Agent.get game, fn state ->
      state.options
      |> Keyword.get(key, default)
    end
  end

  def next(game) do
    reset_done game
    case list game do
      [head | rest] -> Agent.update game, &Map.merge(&1, %{curr: head, list: rest})
      _ -> Agent.update game, &Map.merge(&1, %{curr: nil, state: :inactive})
    end
  end

  def fill(game, songs) do
    Agent.update game, &Map.merge(&1, %{list: songs, state: :active})
  end

  # TODO cleanup

  def set_channel_id(game, channel_id) do
    Agent.update game, &Map.put(&1, :channel_id, channel_id)
  end

  def set_done(game, key) do
    Agent.update game, fn state ->
      Map.put state, :done, Keyword.replace!(state.done, key, true)
    end
  end

  def reset_done(game) do
    Agent.update game, fn state ->
      Map.put state, :done, Keyword.merge(state.done, @initial_done)
    end
  end
end
