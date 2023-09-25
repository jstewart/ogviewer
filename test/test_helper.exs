ExUnit.start(capture_log: true)
Ecto.Adapters.SQL.Sandbox.mode(Ogviewer.Repo, :manual)
Application.ensure_all_started(:bypass)
