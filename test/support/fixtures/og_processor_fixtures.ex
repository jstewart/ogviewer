defmodule Ogviewer.OgProcessorFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ogviewer.OgProcessor` context.
  """

  @doc """
  Generate a url.
  """
  def url_fixture(attrs \\ %{}) do
    {:ok, url} =
      attrs
      |> Enum.into(%{
        url: "https://example.com",
        status: "processing"
      })
      |> Ogviewer.OgProcessor.create_url()

    url
  end
end
