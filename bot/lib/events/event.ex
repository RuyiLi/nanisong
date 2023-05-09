defprotocol MikuBeats.Event do
  @doc """
  https://kraigie.github.io/nostrum/Nostrum.Consumer.html#types
  """
  @spec handle_event(t) :: any
  @fallback_to_any true
  def handle_event(payload)
end

defimpl MikuBeats.Event, for: Any do
  require Logger
  def handle_event(%{__struct__: struct}), do: Logger.warn("Unhandled event #{struct}")
  def handle_event(event), do: Logger.warn("Unhandled event (nostruct) #{inspect(event)}")
end
