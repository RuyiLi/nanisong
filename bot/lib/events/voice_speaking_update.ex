defimpl MikuBeats.Event, for: Nostrum.Struct.Event.SpeakingUpdate do
  require Logger

  alias Nostrum.Api

  @time_between_rounds 5000

  defp maybe_wait(nil), do: nil

  defp maybe_wait(song) do
    :timer.sleep(@time_between_rounds)
    song
  end

  def handle_event(%{speaking: false, guild_id: guild_id}) do
    Logger.debug("Stopped speaking, probably finished a song in #{guild_id}")
    MikuBeats.Songs.reveal_song(guild_id)

    MikuBeats.Registry.fetch!(guild_id)
    |> MikuBeats.Game.next()
    |> MikuBeats.Game.curr()
    |> maybe_wait()
    |> MikuBeats.Songs.play_song(guild_id)
  end

  def handle_event(%{speaking: true, guild_id: guild_id}) do
    MikuBeats.Registry.fetch!(guild_id)
    |> MikuBeats.Game.channel_id()
    |> Api.create_message("get ready for the next round!! :poggers:")
  end
end
