# Ogviewer

[Facebook Open Graph Protocol](https://ogp.me/) preview image viewer created with
[Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) by Jason Stewart

To start the app:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

visit [`localhost:4000`](http://localhost:4000) from your browser, and be amazed.


## Dependencies

- PostgreSQL (14.9 was used for this application.)
- Elixir (latest is fine, I used 1.14 because Emacs LSP crashes on latest)
- Erlang/OTP (latest is fine, 25.3 was used in this application)

## Developing

### Environment setup

To easily install development deps, install [ASDF](https://asdf-vm.com/) then:

- asdf plugin add elixir
- asdf plugin add erlang
- asdf install

### Database setup

This app uses Postgres as a data store, and assumes that you have a `postgres` user
which has a password of `postgres`. This usually works out of the box on macOS with
Postgres.app,

