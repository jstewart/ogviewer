defmodule Ogviewer.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :url, :text
      add :status, :string, default: "processing"
      add :preview_image, :text
      add :error, :text

      timestamps()
    end
  end
end
