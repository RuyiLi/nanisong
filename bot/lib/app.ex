defmodule MikuBeats.Application do
  @moduledoc """
  Entrypoint for MB.
  TODO make application
  TODO restructure so crashes dont mess everything up
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MikuBeats.Consumer,
      MikuBeats.Registry
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
