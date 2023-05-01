
# defmodule MikuBeats.Consumerd do
#   use Nostrum.Consumer

#   alias Nostrum.Api
#   alias Nostrum.Util
#   alias Nostrum.Voice
#   alias Nostrum.Cache.GuildCache
#   alias Nostrum.Constants.ApplicationCommandOptionType, as: CommandType

#   require Logger

#   handle_event = MikuBeats.Events.Handler.handle_event

#   opt = fn type, name, desc, opts ->
#     %{type: type, name: name, description: desc}
#     |> Map.merge(Enum.into(opts, %{}))
#   end

#   @guess_opts [
#     opt.(CommandType.sub_command, "name", "Guess the song",
#       options: [opt.(CommandType.string, "name", "Guess the song name", required: true, autocomplete: true)]
#     ),
#     opt.(CommandType.sub_command, "artist", "Guess the artist",
#       options: [opt.(CommandType.string, "name", "Guess the artist name", required: true, autocomplete: true)]
#     ),
#     opt.(CommandType.sub_command, "anime", "Guess the anime",
#       options: [opt.(CommandType.string, "name", "Guess the anime name", required: true, autocomplete: true)]
#     ),
#   ]

#   @_play_opts [
#     opt.(CommandType.number, "duration", "How long to play each song for", []),
#     opt.(CommandType.number, "duration", "How many rounds", []),
#   ]

#   @commands [
#     {"play", "Start a game of AMQ", []},
#     {"list", "List all answers (dev)", []},
#     {"guess", "Make a guess", @guess_opts},
#   ]

#   def start_link do
#     Consumer.start_link __MODULE__
#   end

#   defp play_song(nil, guild_id), do: Voice.leave_channel(guild_id)
#   defp play_song(%{audio: audio} = song, guild_id) do
#     Logger.info "Now playing #{inspect song}"
#     # duration = MikuBeats.Registry.get_setting(guild_id, :duration, 30)
#     Voice.play guild_id, audio, :url, duration: "30"
#   end

#   defp get_voice_channel_of_interaction(%{guild_id: guild_id, user: %{id: user_id}} = _interaction) do
#     guild_id
#     |> GuildCache.get!
#     |> Map.get(:voice_states)
#     |> Enum.find(%{}, fn v -> v.user_id == user_id end)
#     |> Map.get(:channel_id)
#   end

#   def create_guild_commands(guild_id) do
#     Enum.each(@commands, fn {name, description, options} ->
#       Api.create_guild_application_command(guild_id, %{
#         name: name,
#         description: description,
#         options: options
#       })
#     end)
#   end

#   defp reveal_song(guild_id) do
#     song = MikuBeats.Registry.peek(MikuBeats.Queues, guild_id)

#     MikuBeats.Registry.channel_id(MikuBeats.Queues, guild_id)
#     |> Api.create_message("round over, song was #{inspect song}")
#   end

#   defp maybe_next(guild_id) do
#     if MikuBeats.Registry.done?(MikuBeats.Queues, guild_id) do
#       Voice.stop guild_id
#     end
#   end

#   def handle_event({:READY, %{guilds: guilds} = _event, _ws_state}) do
#     guilds
#     |> Enum.map(fn guild -> guild.id end)
#     |> Enum.each(&create_guild_commands/1)
#   end

#   def handle_event({
#     :INTERACTION_CREATE,
#     %{guild_id: guild_id, type: 4, data: %{options: [%{name: name, options: [%{value: value}]}]}} = interaction,
#     _ws_state
#   }) do
#     # Logger.debug "Autocomplete #{value} #{name} #{Util.maybe_to_atom name}." # Payload is #{inspect interaction, pretty: true}"
#     Api.create_interaction_response interaction, %{type: 8, data: %{
#       choices: autocomplete(value, Util.maybe_to_atom name)
#     }}
#   end

#   def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
#     # Logger.debug "Interaction, payload is #{inspect interaction, pretty: true}"
#     message =
#       case do_command(interaction) do
#         {:msg, msg} -> msg
#         _ -> "okayge"
#       end

#     Api.create_interaction_response interaction, %{type: 4, data: %{content: message}}
#   end

#   def handle_event({:VOICE_SPEAKING_UPDATE, %{speaking: false, guild_id: guild_id} = payload, _ws_state}) do
#     Logger.info "Voice speaking update #{inspect payload}"
#     reveal_song guild_id
#     MikuBeats.Registry.next(MikuBeats.Queues, guild_id)
#     MikuBeats.Registry.peek(MikuBeats.Queues, guild_id)
#     |> play_song(guild_id)
#   end


#   def do_command(%{guild_id: guild_id, channel_id: channel_id, data: %{name: "play", options: options}} = interaction) do
#     case get_voice_channel_of_interaction(interaction) do
#       nil -> {:msg, "ur not in a voice channel"}
#       voice_channel_id ->
#         MikuBeats.Registry.create(
#           MikuBeats.Queues,
#           guild_id,
#           @songs
#           |> Enum.filter(fn song -> song.type !== "INS" end)
#           |> Enum.take_random(10),
#           []
#         )
#         MikuBeats.Registry.set_channel_id MikuBeats.Queues, guild_id, channel_id
#         Voice.join_channel guild_id, voice_channel_id
#     end
#   end

#   def do_command(%{guild_id: guild_id, data: %{name: "list"}}) do
#     {
#       :msg,
#       MikuBeats.Registry.list(MikuBeats.Queues, guild_id)
#       |> case do
#         nil -> "game not found"
#         list ->
#           list
#           |> Enum.map(fn song -> song.name end)
#           |> Enum.join(", ")
#       end
#     }
#   end

#   # TODO clean, wtf is this
#   def do_command(%{
#     guild_id: guild_id,
#     user: %{username: nickname},
#     data: %{name: "guess", options: options},
#   }) do
#     {
#       :msg,
#       MikuBeats.Registry.peek(MikuBeats.Queues, guild_id)
#       |> case do
#         %{name: name, artist: artist, anime: anime} ->
#           case options do
#             [%{name: "name", options: [%{value: guess}]}] ->
#               cond do
#                 String.equivalent? normalize(guess), normalize(name) ->
#                   MikuBeats.Registry.set_done MikuBeats.Queues, guild_id, :song
#                   maybe_next guild_id
#                   "#{nickname} got the **song**!"
#                 true -> "you idiot"
#               end

#             [%{name: "artist", options: [%{value: guess}]}] ->
#               cond do
#                 String.equivalent? normalize(guess), normalize(artist) ->
#                   MikuBeats.Registry.set_done MikuBeats.Queues, guild_id, :artist
#                   maybe_next guild_id
#                   "#{nickname} got the **artist**!"
#                 true -> "you idiot"
#               end

#             [%{name: "anime", options: [%{value: guess}]}] ->
#               cond do
#                 String.equivalent? normalize(guess), normalize(anime) ->
#                   MikuBeats.Registry.set_done MikuBeats.Queues, guild_id, :anime
#                   maybe_next guild_id
#                   "#{nickname} got the **anime**!"
#                 true -> "you idiot"
#               end

#             _ -> "not implemented"
#           end
#         nil -> "there's no game going on rn"
#       end
#     }
#   end
# end
