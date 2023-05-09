defimpl MikuBeats.Event, for: Nostrum.Struct.Guild do
  require Logger

  def handle_event(%{name: name}) do
    Logger.info("On guild #{name}")
  end
end
