defmodule Ogviewer.OgProcessor.SiteTest do
  use ExUnit.Case, async: true

  alias Ogviewer.OgProcessor.Site

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "fetching a URL" do
    test "exception with an invalid url" do
      assert_raise(ArgumentError, fn -> Site.fetch("12345") end)
    end

    test "errors with a non-successful HTTP status", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/", fn conn ->
        Plug.Conn.resp(conn, 500, "server error")
      end)

      assert {:error, "500: server error"} = Site.fetch(endpoint_url(bypass.port))
    end

    test "network errors", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %Mint.TransportError{reason: :econnrefused}} =
               Site.fetch(endpoint_url(bypass.port))

      Bypass.up(bypass)
    end

    test "successful", %{bypass: bypass} do
      success = "<html><title>Success!</title></html>"

      Bypass.expect_once(bypass, "GET", "/", fn conn ->
        Plug.Conn.resp(conn, 200, success)
      end)

      assert {:ok, ^success} = Site.fetch(endpoint_url(bypass.port))
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
