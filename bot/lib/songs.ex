defmodule MikuBeats.Songs do
  @moduledoc """
  Utilities for querying song data.
  TODO defstruct Song
  """

  require Jason
  require Logger

  alias Nostrum.Api
  alias Nostrum.Voice

  import MikuBeats.Util, only: [normalize: 1]

  # Path to JSON file containing song data
  @source "../data/songs.json"
  @external_resource @source

  # Map of song types to atoms.
  @song_types %{
    "OP" => :op,
    "ED" => :ed,
    "INS" => :ins
  }

  # List of songs. %{song, anime, artist, audio}
  @songs File.read!(@source)
         |> Jason.decode!(keys: :atoms)
         |> Enum.map(fn song -> Map.merge(song, %{type: @song_types[song.type]}) end)

  # Maximum number of results that can be returned by an autocomplete interaction
  @max_autocomplete_length 25

  def songs, do: @songs

  @doc """
  Return a list of autocompletion results for a given query and key.
  """
  def autocomplete(query, key) when key in [:song, :anime, :artist] do
    Logger.debug("Attempting to autocomplete `#{query}` for key #{key}")

    contains_query = fn name -> String.contains?(normalize(name), normalize(query)) end
    prefixed_by_query = fn a, _ -> String.starts_with?(normalize(a), normalize(query)) end

    @songs
    |> Enum.map(fn %{^key => name} -> name end)
    |> Enum.filter(contains_query)
    |> Enum.sort(prefixed_by_query)
    |> Enum.uniq()
    |> Enum.take(@max_autocomplete_length)
    |> Enum.map(&%{name: &1, value: &1})
  end

  @doc """
  Randomly retrieve some songs, with an optional filter for song type.
  """
  def take_random(amount, types \\ [:op, :ed]) do
    @songs
    |> Enum.filter(&(&1.type in types))
    |> Enum.take_random(amount)
  end

  @doc """
  Play a song in a given guild.
  """
  def play_song(nil, guild_id) do
    Voice.leave_channel(guild_id)

    MikuBeats.Registry.fetch!(guild_id)
    |> MikuBeats.Game.channel_id()
    |> Api.create_message(
      "game over :polar_bear: hope you've been keeping track of scores because i haven't"
    )
  end

  def play_song(song, guild_id) do
    Logger.info("Now playing #{inspect(song)}")

    duration =
      MikuBeats.Registry.fetch!(guild_id)
      |> MikuBeats.Game.get_opt(:duration)

    Voice.play(guild_id, song.audio, :url, duration: "#{duration}")
  end

  @doc """
  Reveal the song to the active game channel
  """
  def reveal_song(guild_id) do
    pid = MikuBeats.Registry.fetch!(guild_id)
    %{song: song, artist: artist, type: type, anime: anime} = MikuBeats.Game.curr(pid)

    MikuBeats.Game.channel_id(pid)
    |> Api.create_message(
      "round over, the song was **#{song}** by **#{artist}** (the #{type} from **#{anime}**)\nnext round will start in 5 seconds (or not)"
    )
  end

  @doc """
  If all milestones are met, progresses the round
  """
  def maybe_next(guild_id) do
    if MikuBeats.Registry.fetch!(guild_id)
       |> MikuBeats.Game.done?(),
       do: Voice.stop(guild_id)
  end
end
