defmodule Ogviewer.OgProcessor.Url do
  use Ecto.Schema
  import Ecto.Changeset

  schema "urls" do
    field :error, :string
    field :preview_image, :string
    field :status, Ecto.Enum, values: ~w(processing processed error)a
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(url, attrs) do
    url
    |> cast(attrs, [:url, :status, :preview_image, :error])
    |> validate_required([:url])
  end
end
