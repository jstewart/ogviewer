defmodule Ogviewer.OgProcessor.Site do
  @moduledoc """
  Site loader and processor for the OgViewer
  """

  def fetch(url) do
    case Req.get(url) do
      {:ok, %Req.Response{body: body}} ->
        {:ok, body}
      {:error, error} ->
        {:error, error}
    end
  end
end
