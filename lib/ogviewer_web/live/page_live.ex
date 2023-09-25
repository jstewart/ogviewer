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
    <h1 class="font-bold text-xl mb-3 text-center">OpenGraph Protocol Preview Image Viewer</h1>
    <form class="px-5" phx-submit="preview">
      <div class="flex min-w-full">
      <div class="w-4/5" >
      <input class="w-full disabled:bg-gray-200" type="text" autocomplete="off" name="url" value={@url} disabled={@running} />
      <%= if @error do %>
        <p class="text-red-500"><%= @error %></p>
      <% end %>
      </div>
      <button class="ml-3 bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded disabled:opacity-75" disabled={@running}>Preview</button>
      </div>
      <div class="w-full px-5 mt-5">
        <%= if @preview_image do %>
          <img src={@preview_image} % />
        <% end %>
      </div>
    </form>
    """
  end
end
