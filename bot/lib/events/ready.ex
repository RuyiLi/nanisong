defimpl MikuBeats.Event.Protocol, for: Nostrum.Struct.Event.Ready do
  require Logger

  def handle_event(%{guilds: guilds, user: user, v: v}) do
    Logger.info """
      #{user.username}##{user.discriminator}. #{length guilds} guilds. Gateway version: #{v}.
    """
  end
end
