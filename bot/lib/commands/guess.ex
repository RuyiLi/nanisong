defmodule MikuBeats.Commands.Guess do
  @moduledoc """
  Make a guess
  """

  @behaviour MikuBeats.Command

  require Logger

  alias Nostrum.Constants.ApplicationCommandOptionType, as: CommandType

  import MikuBeats.Util, only: [normalize: 1]

  def name, do: "guess"
  def description, do: "Gamble"

  def options,
    do: [
      %{
        type: CommandType.sub_command(),
        name: "song",
        description: "Guess the song name",
        options: [
          %{
            type: CommandType.string(),
            name: "name",
            description: "Guess the song name",
            required: true,
            autocomplete: true
          }
        ]
      },
      %{
        type: CommandType.sub_command(),
        name: "artist",
        description: "Guess the artist name",
        options: [
          %{
            type: CommandType.string(),
            name: "name",
            description: "Guess the artist name",
            required: true,
            autocomplete: true
          }
        ]
      },
      %{
        type: CommandType.sub_command(),
        name: "anime",
        description: "Guess the anime name",
        options: [
          %{
            type: CommandType.string(),
            name: "name",
            description: "Guess the anime name",
            required: true,
            autocomplete: true
          }
        ]
      }
    ]

  defp check_song(pid, song, %{
         guild_id: guild_id,
         user: %{username: nickname},
         data: %{name: "guess", options: [%{name: name, options: [%{value: guess}]}]}
       })
       when name in ["song", "artist", "anime"] do
    target = Nostrum.Util.maybe_to_atom(name)
    answer = song[target]

    Logger.debug("[#{target}] Answer is #{answer}, user #{nickname} guessed #{guess}")

    if String.equivalent?(normalize(guess), normalize(answer)) do
      MikuBeats.Game.complete_milestone(pid, target)
      MikuBeats.Songs.maybe_next(guild_id)
      "#{nickname} got the **#{name}**!"
    else
      "wrong"
    end
  end

  @impl true
  def execute(%{guild_id: guild_id} = interaction) do
    pid = MikuBeats.Registry.fetch!(guild_id)

    case MikuBeats.Game.curr(pid) do
      nil -> "there's no game going on rn"
      song -> check_song(pid, song, interaction)
    end
  end
end
