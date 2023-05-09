defimpl MikuBeats.Event, for: Nostrum.Struct.Interaction do
  @moduledoc """
  Event handler for the INTERACTION_CREATE event
  """

  alias Nostrum.Api

  @guess_key_to_atom %{
    "song" => :song,
    "anime" => :anime,
    "artist" => :artist
  }

  @doc """
  Handles autocomplete for the guess command
  name should be limited to the song, anime, artist
  """
  def handle_event(%{type: 4, data: %{options: options}} = interaction) do
    case options do
      [%{name: name, options: [%{value: value}]}] ->
        Api.create_interaction_response(interaction, %{
          type: 8,
          data: %{
            choices: MikuBeats.Songs.autocomplete(value, @guess_key_to_atom[name])
          }
        })
    end
  end

  def handle_event(interaction) do
    Api.create_interaction_response(
      interaction,
      %{
        type: 4,
        data: %{content: MikuBeats.Commands.execute(interaction)}
      }
    )
  end
end
