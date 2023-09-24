defmodule Ogviewer.OgProcessor.Site do
  @moduledoc """
  Site loader and processor for the OgViewer
  """

  @doc """
  Fetches a HTTP resource, handling common errors
  """
  def fetch(url) do
    # Note that we _may_ want to retry someday, if and only if
    # it doesn't interfere with the user's experience
    with {:ok, response} <- Req.get(url, retry: false),
         %Req.Response{status: 200, body: body} <- response do
      {:ok, body}
    else
      # Non-200 responses
      %Req.Response{status: status, body: body} ->
        {:error, "#{status}: #{String.slice(body, 0..200)}"}

      # Handles network and misc errors
      {:error, error} ->
        {:error, error}
    end
  end
end
