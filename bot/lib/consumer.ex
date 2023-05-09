defmodule MikuBeats.Consumer do
  @moduledoc """
  Nostrum event consumer
  """

  use Nostrum.Consumer

  require Logger

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({_type, payload, _ws_state}),
    do: MikuBeats.Event.handle_event(payload)

  def handle_event(_event), do: nil
end
