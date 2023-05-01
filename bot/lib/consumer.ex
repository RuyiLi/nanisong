
defmodule MikuBeats.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Util
  alias Nostrum.Voice
  alias Nostrum.Cache.GuildCache
  alias Nostrum.Constants.ApplicationCommandOptionType, as: CommandType

  require Logger

  def start_link do
    Consumer.start_link __MODULE__
  end

  def handle_event({_type, payload, _ws_state}), do: MikuBeats.Event.Protocol.handle_event payload
  def handle_event(_event), do: nil
end
