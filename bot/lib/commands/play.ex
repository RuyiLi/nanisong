defmodule MikuBeats.Commands.Play do
  @moduledoc """
  Command to start a round of AMQ.
  """

  @behaviour MikuBeats.Command

  require Logger

  alias Nostrum.Voice
  alias Nostrum.Cache.GuildCache
  alias Nostrum.Constants.ApplicationCommandOptionType, as: CommandType
  alias Nostrum.Struct.ApplicationCommandInteractionDataOption, as: Opt

  @opt_key_to_atom %{
    "duration" => :duration,
    "rounds" => :rounds
  }

  def name, do: "play"
  def description, do: "Start a round of AMQ"

  def options,
    do: [
      %{
        type: CommandType.integer(),
        name: "duration",
        description: "How long to play each song for"
      },
      %{
        type: CommandType.integer(),
        name: "rounds",
        description: "The number of rounds"
      }
    ]

  defp map_from_opts(nil), do: MikuBeats.Game.default_options()

  defp map_from_opts(options),
    do:
      MikuBeats.Game.default_options()
      |> Map.merge(
        options
        |> Enum.map(fn %Opt{name: name, value: value} -> {@opt_key_to_atom[name], value} end)
        |> Map.new()
      )

  defp start_game(guild_id, channel_id, voice_channel_id, options) do
    options = map_from_opts(options)
    Logger.debug("play options #{inspect(options)}")

    MikuBeats.Registry.create(guild_id,
      options: options,
      channel_id: channel_id,
      list: MikuBeats.Songs.take_random(options.rounds)
    )

    Voice.join_channel(guild_id, voice_channel_id)
  end

  defp game_status(guild_id) do
    case MikuBeats.Registry.fetch(guild_id) do
      {:ok, pid} ->
        case MikuBeats.Game.curr(pid) do
          nil -> :inactive
          _song -> :ingame
        end

      _ ->
        :noinstance
    end
  end

  @impl true
  def execute(%{
        guild_id: guild_id,
        channel_id: channel_id,
        user: %{id: user_id},
        data: %{name: "play", options: options}
      }) do
    guild_id
    |> GuildCache.get!()
    |> Map.get(:voice_states)
    |> Enum.find(%{}, fn voice_state -> voice_state.user_id == user_id end)
    |> Map.get(:channel_id)
    |> case do
      nil ->
        "ur not in a voice channel"

      voice_channel_id ->
        case game_status(guild_id) do
          :inactive ->
            MikuBeats.Registry.remove!(guild_id)
            start_game(guild_id, channel_id, voice_channel_id, options)

          :noinstance ->
            start_game(guild_id, channel_id, voice_channel_id, options)

          :ingame ->
            "ur already in a game :angry:"
        end
    end
  end
end
