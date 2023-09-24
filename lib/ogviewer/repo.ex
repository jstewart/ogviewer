defmodule Ogviewer.Repo do
  use Ecto.Repo,
    otp_app: :ogviewer,
    adapter: Ecto.Adapters.Postgres
end
