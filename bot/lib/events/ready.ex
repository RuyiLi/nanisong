defimpl MikuBeats.Event, for: Nostrum.Struct.Event.Ready do
  require Logger

  def handle_event(%{guilds: guilds, user: user}) do
    Logger.info("#{user.username}##{user.discriminator}. #{length(guilds)} guilds.")

    guilds
    |> Enum.map(fn guild -> guild.id end)
    |> Enum.each(&MikuBeats.Commands.create_guild_commands/1)
  end
end
