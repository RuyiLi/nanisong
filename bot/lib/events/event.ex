defprotocol MikuBeats.Event.Protocol do
  @doc """
  https://kraigie.github.io/nostrum/Nostrum.Consumer.html#types
  """
  @spec handle_event(t) :: any
  @fallback_to_any true
  def handle_event(payload)
end

defimpl MikuBeats.Event.Protocol, for: Any do
  def handle_event(event), do: nil
end
