defmodule MikuBeats.Songs do
  @moduledoc """
    Utilities for retrieving song data.
  """

  require Jason

  @source "../data/songs.json"
  @external_resource @source
  @songs (
    File.read!(@source)
    |> Jason.decode!(keys: :atoms)
  )

  @max_autocomplete_length 25

  defp normalize(str) do
    str
    |> String.downcase
  end

  defp filter_prefix(list, query, key) do
    list
    |> Enum.filter
        fn %{^key => name} ->
          String.starts_with? normalize(name), normalize(query)
        end
  end

  defp maybe_append_contains(list, query, key) when length(list) >= @max_autocomplete_length, do: list
  defp maybe_append_contains(list, query, key) do
    list
    |> Enum.filter
        fn %{^key => name} ->
          String.contains? normalize(name), normalize(query)
        end
  end

  def autocomplete(query, key) when key in [:song, :anime, :artist] do
    @songs
    |> filter_prefix(query, key)
    |> Enum.take(@max_autocomplete_length)
    |> maybe_append_contains(query, key)
    |> Enum.map(fn %{^key => name} -> name end)
    |> Enum.uniq
    |> Enum.map(fn name -> %{name: name, value: name} end)
  end
end
