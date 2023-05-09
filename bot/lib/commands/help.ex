defmodule MikuBeats.Commands.Help do
  @moduledoc """
  Get help
  """

  @behaviour MikuBeats.Command

  def name, do: "help"
  def description, do: "Get help"
  def options, do: %{}

  @help_msg """
    :wave: hi, im an AMQ bot
    do /play to start a round of AMQ
    do /guess artist/song/anime to guess the artist/song/anime
    do /help to see this message again
    @6463#6463 to report anything/give feedback or whatever

    things i am missing:
    - aliases/series collapsing
    - songs past the S23 anime season (the one with hells paradise and oshi no ko)
    - friends
    - filter for op, ed, ins
    - connecting to MAL/AL accounts
    - scoreboard
    - split if multiple artists
  """

  @impl true
  def execute(_interaction), do: @help_msg
end
