defmodule MikuBeats.Registry do
  @moduledoc """
  Process registry for Game agents.
  """

  require Logger
  require Registry

  @registry :games

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_opts) do
    {:ok, _} = Registry.start_link(keys: :unique, name: @registry)
  end

  def create(guild_id, opts) do
    Logger.debug("Registry entry: {#{guild_id}, #{inspect(opts)}}")
    name = {:via, Registry, {@registry, guild_id}}
    {:ok, _} = MikuBeats.Game.start_link(Map.new(opts), name: name)
  end

  def remove!(guild_id) do
    case Registry.lookup(@registry, guild_id) do
      [{pid, nil}] ->
        Logger.debug("removing #{inspect(pid)}")
        Registry.unregister(@registry, guild_id)
        Process.exit(pid, :kill)
    end
  end

  def fetch(guild_id) do
    case Registry.lookup(@registry, guild_id) do
      [{pid, nil}] -> {:ok, pid}
      _ -> nil
    end
  end

  def fetch!(guild_id) do
    case Registry.lookup(@registry, guild_id) do
      [{pid, nil}] -> pid
    end
  end
end
