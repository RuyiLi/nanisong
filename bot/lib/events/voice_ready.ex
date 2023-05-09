defimpl MikuBeats.Event, for: Nostrum.Struct.Event.VoiceReady do
  require Logger

  def handle_event(%{guild_id: guild_id}) do
    Logger.info("Ready to play in #{guild_id}")

    MikuBeats.Registry.fetch!(guild_id)
    |> MikuBeats.Game.next()
    |> MikuBeats.Game.curr()
    |> MikuBeats.Songs.play_song(guild_id)
  end
end
