defmodule Ogviewer.OgProcessor.SiteTest do
  use ExUnit.Case, async: true

  alias Ogviewer.OgProcessor.Site
  alias Ogviewer.OgProcessor.Url

  describe "fetching a URL" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "exception with an invalid url" do
      assert_raise(ArgumentError, fn -> Site.fetch(%Url{url: "12345"}) end)
    end

    test "errors with a non-successful HTTP status", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/", fn conn ->
        Plug.Conn.resp(conn, 500, "server error")
      end)

      assert {:error, "500: server error"} = Site.fetch(%Url{url: endpoint_url(bypass.port)})
    end

    test "network errors", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %Mint.TransportError{reason: :econnrefused}} =
               Site.fetch(%Url{url: endpoint_url(bypass.port)})

      Bypass.up(bypass)
    end

    test "successful", %{bypass: bypass} do
      success = "<html><title>Success!</title></html>"

      Bypass.expect_once(bypass, "GET", "/", fn conn ->
        Plug.Conn.resp(conn, 200, success)
      end)

      assert {:ok, ^success} = Site.fetch(%Url{url: endpoint_url(bypass.port)})
    end
  end

  @html_without_og """
  <html>
  <head>
  <title>Test</title>
  </head>
  <body>
    <div class="content">
      <a href="http://google.com" class="js-google js-cool" data-action="lolcats">Google</a>
      <a href="http://elixir-lang.org" class="js-elixir js-cool">Elixir lang</a>
      <a href="http://java.com" class="js-java">Java</a>
    </div>
  </body>
  </html>
  """

  @html_with_og """
  <html>
  <head>
  <meta property="og:title" content="Luna Care - Physical therapy, delivered to you">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://www.getluna.com/">
  <meta property="og:image" content="https://www.getluna.com/assets/images/we_come_to_you.svg">
  <title>Test</title>
  </head>
  <body>
    <div class="content">
      <a href="http://google.com" class="js-google js-cool" data-action="lolcats">Google</a>
      <a href="http://elixir-lang.org" class="js-elixir js-cool">Elixir lang</a>
      <a href="http://java.com" class="js-java">Java</a>
    </div>
  </body>
  </html>
  """

  describe "parsing the preview image" do
    test "errors when the preview image is missing" do
      assert {:error, :not_found} = Site.parse(@html_without_og)
    end

    test "returns the preview image" do
      assert {:ok, "https://www.getluna.com/assets/images/we_come_to_you.svg"} =
               Site.parse(@html_with_og)
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
