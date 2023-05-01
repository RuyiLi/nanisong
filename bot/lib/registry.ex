defmodule MikuBeats.Registry do
  use GenServer

  require Logger

  # Client
  def start_link(opts \\ []) do
    GenServer.start_link __MODULE__, :ok, opts
  end

  # Maybe hardcode pid to MikuBeats.Queues
  # surely there must be some way to abstract this

  def create(pid, guild_id, elems, opts \\ []) do
    Logger.debug "Calling create with #{inspect elems, pretty: true}"
    GenServer.cast pid, {:create, guild_id, elems, opts}
  end

  def next(pid, guild_id) do
    GenServer.cast pid, {:next, guild_id}
  end

  def reset_done(pid, guild_id) do
    GenServer.cast pid, {:reset_done, guild_id}
  end

  def set_done(pid, guild_id, key) do
    GenServer.cast pid, {:set_done, guild_id, key}
  end

  def set_channel_id(pid, guild_id, channel_id) do
    GenServer.cast pid, {:set_channel_id, guild_id, channel_id}
  end

  def done?(pid, guild_id) do
    GenServer.call pid, {:done?, guild_id}
  end

  def list(pid, guild_id) do
    GenServer.call pid, {:list, guild_id}
  end

  def peek(pid, guild_id) do
    GenServer.call pid, {:peek, guild_id}
  end

  def channel_id(pid, guild_id) do
    GenServer.call pid, {:channel_id, guild_id}
  end

  def get_setting(pid, guild_id, key, default) do
    GenServer.call pid, {:setting, guild_id, key, default}
  end

  # Server
  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:create, guild_id, list, opts}, games) do
    case Map.fetch(games, guild_id) do
      {:ok, game} ->
        if is_nil(MikuBeats.Game.curr game) do
          MikuBeats.Game.fill game, list
          {:noreply, games}
        end
      :error ->
        {:ok, game} = MikuBeats.Game.start_link opts
        MikuBeats.Game.fill game, list
        {:noreply, Map.put(games, guild_id, game)}
    end
  end

  # TODO cleanup

  @impl true
  def handle_cast({:next, guild_id}, games) do
    Map.fetch!(games, guild_id)
    |> MikuBeats.Game.next
    {:noreply, games}
  end

  @impl true
  def handle_cast({:reset_done, guild_id}, games) do
    Map.fetch!(games, guild_id)
    |> MikuBeats.Game.reset_done
    {:noreply, games}
  end

  @impl true
  def handle_cast({:set_done, guild_id, key}, games) do
    Map.fetch!(games, guild_id)
    |> MikuBeats.Game.set_done(key)
    {:noreply, games}
  end

  @impl true
  def handle_cast({:set_channel_id, guild_id, channel_id}, games) do
    Map.fetch!(games, guild_id)
    |> MikuBeats.Game.set_channel_id(channel_id)
    {:noreply, games}
  end

  # Calls

  @impl true
  def handle_call({:done?, guild_id}, _from, games) do
    case Map.fetch(games, guild_id) do
      {:ok, game} -> {:reply, MikuBeats.Game.done?(game), games}
      :error -> {:reply, false, games}
    end
  end

  @impl true
  def handle_call({:list, guild_id}, _from, games) do
    case Map.fetch(games, guild_id) do
      {:ok, game} -> {:reply, MikuBeats.Game.list(game), games}
      :error -> {:reply, nil, games}
    end
  end

  @impl true
  def handle_call({:channel_id, guild_id}, _from, games) do
    case Map.fetch(games, guild_id) do
      {:ok, game} -> {:reply, MikuBeats.Game.channel_id(game), games}
      :error -> {:reply, nil, games}
    end
  end

  # @impl true
  # def handle_call({:out, guild_id}, _from, games) do
  #   case Map.fetch(games, guild_id) do
  #     {:ok, game} ->
  #       game
  #       |> :queue.out
  #       |> case do
  #         {{:value, front}, new_queue} -> {:reply, front, Map.put(queues, guild_id, new_game)}
  #         {:empty, _queue} -> {:reply, nil, games}
  #       end
  #     :error -> {:reply, nil, games}
  #   end
  # end

  @impl true
  def handle_call({:peek, guild_id}, _from, games) do
    case Map.fetch(games, guild_id) do
      {:ok, game} ->
        # Logger.debug "Peek: #{inspect MikuBeats.Game.curr game}"
        {:reply, MikuBeats.Game.curr(game), games}
      :error ->
        Logger.debug "peek failed"
        {:reply, nil, games}
    end
  end

  @impl true
  def handle_call({:setting, guild_id, key, default}, _from, games) do
    case Map.fetch(games, guild_id) do
      {:ok, game} -> {:reply, MikuBeats.Game.get_setting(game, key, default), games}
      :error -> {:reply, nil, games}
    end
  end
end
