defmodule MikuBeats do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      MikuBeats.Consumer,
      # {MikuBeats.Registry, [name: MikuBeats.Queues]},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
