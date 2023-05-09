defmodule MikuBeats.Game do
  @moduledoc """
  A game instance.
  query - curr, list
  mutate - next, clear, create
  All mutations return the pid passed in as the first parameter
  """

  use Agent

  @initial_milestones [
    song: false,
    artist: false,
    anime: false
  ]

  @default_options %{
    duration: 30,
    rounds: 20
  }

  @default_state %{
    curr: nil,
    list: [],
    milestones: @initial_milestones,
    channel_id: nil,
    options: @default_options
  }

  def start_link(opts, agent_opts) do
    Agent.start_link(fn -> Map.merge(@default_state, opts) end, agent_opts)
  end

  def default_options, do: @default_options

  # Queries

  defp fetch(pid, prop), do: Agent.get(pid, &Map.get(&1, prop))

  def curr(pid), do: fetch(pid, :curr)
  def list(pid), do: fetch(pid, :list)
  def channel_id(pid), do: fetch(pid, :channel_id)

  def get_opt(pid, key),
    do:
      fetch(pid, :options)
      |> Map.get(key)

  def done?(pid) do
    Agent.get(pid, fn state ->
      state.milestones
      |> Keyword.values()
      |> Enum.all?()
    end)
  end

  # Mutations

  def reset_milestones(pid) do
    Agent.update(pid, &Map.merge(&1, %{milestones: @initial_milestones}))
    pid
  end

  def complete_milestone(pid, key) do
    Agent.update(pid, &Map.put(&1, :milestones, Keyword.replace!(&1.milestones, key, true)))
    pid
  end

  def next(pid) do
    pid
    |> reset_milestones()
    |> list()
    |> case do
      [head | rest] -> Agent.update(pid, &Map.merge(&1, %{curr: head, list: rest}))
      _ -> Agent.update(pid, &Map.merge(&1, %{curr: nil, state: :inactive}))
    end

    pid
  end
end
