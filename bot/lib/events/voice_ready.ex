defimpl MikuBeats.Event.Protocol, for: Nostrum.Struct.Event.VoiceReady do
  require Logger
  def handle_event(%{guild_id: guild_id}) do
    Logger.info "voiceready"

    MikuBeats.Registry.next(MikuBeats.Queues, guild_id)
    MikuBeats.Registry.peek(MikuBeats.Queues, guild_id)
    # |> play_song(guild_id)
  end
end
