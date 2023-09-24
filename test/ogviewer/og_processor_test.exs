defmodule Ogviewer.OgProcessorTest do
  use Ogviewer.DataCase

  alias Ogviewer.OgProcessor

  describe "urls" do
    alias Ogviewer.OgProcessor.Url

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
      update_attrs = %{error: "some updated error", preview_image: "some updated preview_image", status: :error}

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
end
