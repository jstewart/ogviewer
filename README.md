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
Postgres.app. 

Note that this is not production-ready. Database connections should always be configured
via environment variables injected into deployment via secure parameter storage or similar.

## Implementation

Note that my liveview skills are rudimentary, as I am primarily a backend engineer. Hence,
my focus is on the backend portion of the application.

One thing I would liked to have done is taken advantage of LiveView's end-to-end testing 
but I'm not familiar enough with it to effectively implement it.

My general strategy was to start developing from the inside out, like a true 
backend developer :)

I started with the heart of the application, the URL fetcher and meta tag parser.

### Background Processing

We have a couple of choices here. We could use a background job runner, such as
[Oban](https://github.com/sorentwo/oban), which would give us retries, persistence 
across restarts, and a bunch of other nice things, but for this exercise, OTP 
makes this VERY simple. 

We can easily spawn a background process or task when handling the `preview` message sent 
to LiveView. We simply wrap this in an Elixir `Task`, then the task sends a message back
to the LiveView process with the result. 

This all works beautifully because [LiveView is a process](https://fly.io/phoenix-files/a-liveview-is-a-process/).

### Data Storage

Since Phoenix already ships with Postgres, we'll be using that as our storage layer.
Redis could have been used, but it's not worth the extra dependency in this case.
Redis is faster than PostgreSQL for simple KV lookups, but not fast enough to warrant
boostrapping redis.

Given that LiveView can easily spin up processes and report status back to it's originating
PID, we don't really _need_ postgres, so I'm treating it as a historical record of lookups
for a specific URL. At some point any app will need a database anyway, so I decided to just 
work with it instead of avoiding it.

### Testing

I decided to test as I built the components of the system, starting with HTTP.
Testing HTTP can be difficult, as you're usually just hitting mocks, and that's 
kind of worthless! Elixir has an excellent library called Bypass that allows us 
to simulate real HTTP connections to whatever client that we may be using to make
a request. I've exercised that liberally here because I'm a big believer in testing
as close to "real" interactions as we can.
