defmodule MikuBeats.Event.SSS do
  @moduledoc """

  """

  require Logger

  # @before_compile :check_duplicate_events

  # defp check_duplicate_events do
  #   @modules
  #   |> Enum.frequencies_by(fn mod -> mod.event end)
  #   |> Enum.each(fn {mod, freq} ->
  #     if freq > 1, do: Logger.warn "Multiple event handlers for #{mod.event}."
  #   end)
  # end

  def handle_event({_type, payload, _ws_state}), do: MikuBeats.Event.Protocol.handle_event payload
end
