defmodule MikuBeats.Commands do
  @moduledoc """
  Main interface for loading and executing commands.
  """

  alias Nostrum.Api

  require Logger

  @command_list [
    MikuBeats.Commands.Play,
    MikuBeats.Commands.Help,
    MikuBeats.Commands.Guess
  ]

  @commands @command_list
            |> Enum.map(fn cmd -> {cmd.name, cmd} end)
            |> Map.new()

  def create_guild_commands(guild_id) do
    Enum.each(@command_list, fn cmd ->
      Logger.info("Creating guild commands for #{guild_id}.")

      Api.create_guild_application_command(guild_id, %{
        name: cmd.name,
        description: cmd.description,
        options: cmd.options
      })
    end)
  end

  def execute(%{data: %{name: name}} = interaction) do
    Logger.debug("Attempting to execute command [#{name}]")

    @commands
    |> Map.fetch!(name)
    |> (& &1.execute(interaction)).()
  end
end
