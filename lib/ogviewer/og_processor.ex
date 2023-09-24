defmodule Ogviewer.OgProcessor do
  @moduledoc """
  The OgProcessor context.

  Note that a lof of this functionality will
  be unusued for the Luna exercise, but it would
  be nice to have if iterating on a solution.
  """

  import Ecto.Query, warn: false
  alias Ogviewer.Repo

  alias Ogviewer.OgProcessor.Url
  alias Ogviewer.OgProcessor.Site

  require Logger

  @doc """
  Returns the list of urls.

  ## Examples

      iex> list_urls()
      [%Url{}, ...]

  """
  def list_urls do
    Repo.all(Url)
  end

  @doc """
  Gets a single url.

  Raises `Ecto.NoResultsError` if the Url does not exist.

  ## Examples

      iex> get_url!(123)
      %Url{}

      iex> get_url!(456)
      ** (Ecto.NoResultsError)

  """
  def get_url!(id), do: Repo.get!(Url, id)

  @doc """
  Creates a url.

  ## Examples

      iex> create_url(%{field: value})
      {:ok, %Url{}}

      iex> create_url(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_url(attrs \\ %{}) do
    %Url{}
    |> Url.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a url.

  ## Examples

      iex> update_url(url, %{field: new_value})
      {:ok, %Url{}}

      iex> update_url(url, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_url(%Url{} = url, attrs) do
    url
    |> Url.changeset(attrs)
    |> Repo.update()
  end

  # @doc """
  # Updates a url (same as update_url but throws an exception on failure).
  # """
  # def update_url!(%Url{} = url, attrs) do
  #   url
  #   |> Url.changeset(attrs)
  #   |> Repo.update!()
  # end

  @doc """
  Deletes a url.

  ## Examples

      iex> delete_url(url)
      {:ok, %Url{}}

      iex> delete_url(url)
      {:error, %Ecto.Changeset{}}

  """
  def delete_url(%Url{} = url) do
    Repo.delete(url)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking url changes.

  ## Examples

      iex> change_url(url)
      %Ecto.Changeset{data: %Url{}}

  """
  def change_url(%Url{} = url, attrs \\ %{}) do
    Url.changeset(url, attrs)
  end

  @doc """
  Fetches an opengraph preview image from a %URL{}, recording
  the status of the operation in the database

  Returns {:ok, %Url{}} when successful,
  {:error, "error"} when unsuccessful

  ## Examples

      iex> process_url(url)
      {:ok, %Url{preview_image: "https://example.com/image.png"}}
  """
  def process_url(%Url{} = url) do
    with {:ok, html_body} <- Site.fetch(url),
         {:ok, preview_image} <- Site.parse(html_body),
         {:ok, url} <- update_url(url, %{status: :processed, preview_image: preview_image}) do
      Logger.info("processed url: #{url.url}")

      {:ok, url}
    else
      {:error, error} ->
        Logger.error("error processing url #{url.url}")
         update_url(url, %{status: :error, errors: inspect(error)})
        {:error, error}
    end
  end
end
