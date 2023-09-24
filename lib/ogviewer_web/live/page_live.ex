defmodule OgviewerWeb.PageLive do
  use Phoenix.LiveView

  alias Ogviewer.OgProcessor
  alias Ogviewer.OgProcessor.Url

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:preview_image, nil)
      |> assign(:url, nil)
      |> assign(:error, nil)
      |> assign(:running, false)

    {:ok, socket}
  end

  def handle_event("preview", %{"url" => url}, socket) do
    socket =
      socket
      |> assign(:url, url)
      |> assign(:running, true)

    Task.async(fn ->
      case OgProcessor.create_url(%{url: url}) do
        {:ok, url} ->
          try_process_url(url)

        {:error, _error} ->
          {:error, :invalid_url}
      end
    end)

    {:noreply, socket}
  end

  defp try_process_url(url) do
    case OgProcessor.process_url(url) do
      {:ok, url} ->
        {:ok, url}

      {:error, error} ->
        OgProcessor.update_url(url, %{errors: inspect(error), status: :error})
        {:error, error}
    end
  end

  def handle_info({ref, result}, socket) do
    Process.demonitor(ref, [:flush])

    assigns_data =
      case result do
        {:ok, %Url{preview_image: image}} ->
          [preview_image: image, error: nil]

        {:error, :invalid_url} ->
          [preview_image: nil, error: "Invalid URL"]

        {:error, %Ecto.Changeset{}} ->
          [preview_image: nil, error: "Error saving/updating URL"]

        {:error, :not_found} ->
          [preview_image: nil, error: "No OpenGraph Image for this URL"]

        {:error, _error} ->
          [
            preview_image: nil,
            error: "An unknown error has occurred. Check the URL and try again"
          ]
      end

    socket =
      socket
      |> assign(assigns_data)
      |> assign(:running, false)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>OpenGraph Protocol Preview Image Viewer</h1>
    <form phx-submit="preview">
      <input type="text" autocomplete="off" name="url" value={@url} disabled={@running} />
      <%= if @error do %>
        <p><%= @error %></p>
      <% end %>
      <button disabled={@running}>Preview</button>
      <div>
        <%= if @preview_image do %>
          <img src={@preview_image} % />
        <% end %>
      </div>
    </form>
    """
  end
end
