defmodule Ogviewer.OgProcessorTest do
  use Ogviewer.DataCase

  alias Ogviewer.OgProcessor
  alias Ogviewer.OgProcessor.Url

  describe "urls" do
    import Ogviewer.OgProcessorFixtures

    @invalid_attrs %{error: nil, preview_image: nil, status: nil, url: nil}

    test "list_urls/0 returns all urls" do
      url = url_fixture()
      assert OgProcessor.list_urls() == [url]
    end

    test "get_url!/1 returns the url with given id" do
      url = url_fixture()
      assert OgProcessor.get_url!(url.id) == url
    end

    test "create_url/1 with valid data creates a url" do
      valid_attrs = %{url: "https://example.com", status: :processing}

      assert {:ok, %Url{} = url} = OgProcessor.create_url(valid_attrs)
      assert url.url == "https://example.com"
      assert url.status == :processing
    end

    test "create_url/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = OgProcessor.create_url(@invalid_attrs)
    end

    test "update_url/2 with valid data updates the url" do
      url = url_fixture()

      update_attrs = %{
        error: "some updated error",
        preview_image: "some updated preview_image",
        status: :error
      }

      assert {:ok, %Url{} = url} = OgProcessor.update_url(url, update_attrs)
      assert url.error == "some updated error"
      assert url.preview_image == "some updated preview_image"
      assert url.status == :error
    end

    test "update_url/2 with invalid data returns error changeset" do
      url = url_fixture()
      assert {:error, %Ecto.Changeset{}} = OgProcessor.update_url(url, @invalid_attrs)
      assert url == OgProcessor.get_url!(url.id)
    end

    test "delete_url/1 deletes the url" do
      url = url_fixture()
      assert {:ok, %Url{}} = OgProcessor.delete_url(url)
      assert_raise Ecto.NoResultsError, fn -> OgProcessor.get_url!(url.id) end
    end

    test "change_url/1 returns a url changeset" do
      url = url_fixture()
      assert %Ecto.Changeset{} = OgProcessor.change_url(url)
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
  describe "process_url" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "returns an error for an invalid url" do
      {:ok, url} = OgProcessor.create_url(%{url: "foo"})
      assert {:error, "scheme is required for url: foo"} = OgProcessor.process_url(url)
    end

    test "errors when preview image is not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/", fn conn ->
        Plug.Conn.resp(conn, 200, @html_without_og)
      end)

      {:ok, url} = OgProcessor.create_url(%{url: endpoint_url(bypass.port)})
      assert {:error, :not_found} = OgProcessor.process_url(url)
    end

    test "returns a %Url{} with a preview image", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/", fn conn ->
        Plug.Conn.resp(conn, 200, @html_with_og)
      end)

      {:ok, url} = OgProcessor.create_url(%{url: endpoint_url(bypass.port)})
      assert {:ok,
              %Url{preview_image: "https://www.getluna.com/assets/images/we_come_to_you.svg"}} =
               OgProcessor.process_url(url)
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
