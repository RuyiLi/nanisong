defmodule MikuBeats.Command do
  @moduledoc """
  Behavior for an application command
  """

  @doc """
  String representing the application command description
  """
  @callback name :: String.t()

  @doc """
  String representing the application command description
  """
  @callback description :: String.t()

  @doc """
  A list of options, as defined by https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-structure.
  TODO change return type
  """
  @callback options :: any

  @doc """
  Function to be executed when an interaction is made with this command
  """
  @callback execute(interaction :: Nostrum.Struct.Interaction) :: any
end
