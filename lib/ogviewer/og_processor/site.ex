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

  @doc """
  Parses a site's preview image.
  See: https://ogp.me/

  Returns a tuple of {:ok, image} - when successful,
  {:error, :not_found} - When the preview image is not specified, or
  {:error, some_floki_parsing_error} when Floki couldn't parse the HTML
  """
  def parse(html) do
    with {:ok, document} <- Floki.parse_document(html),
         [{"meta", [{"property", "og:image"}, {"content", preview_image}], []}] <-
           Floki.find(document, "meta[property='og:image']") do
      {:ok, preview_image}
    else
      {:error, floki_error} ->
        {:error, floki_error}

      _ ->
        {:error, :not_found}
    end
  end
end
