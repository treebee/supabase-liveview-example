defmodule SupabaseLiveviewExampleWeb.Components.Avatar do
  use SupabaseLiveviewExampleWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <img src="<%= @image_url %>" class="w-24 h-24 border border-grey-600 rounded-md mr-4">
    """
  end

  @impl true
  def update(%{avatar_url: avatar_url} = assigns, socket) do
    socket =
      cond do
        avatar_url in ["", nil] ->
          assign(socket, image_url: "")

        true ->
          user_id = assigns.user["id"]
          conn = SupabaseLiveviewExample.Supabase.get_connection()
          {:ok, image} = Supabase.Storage.Objects.get(conn, Path.join(["avatars", avatar_url]))

          dest =
            Path.join([
              :code.priv_dir(:supabase_liveview_example),
              "static",
              "avatars",
              user_id
            ])

          File.mkdir_p!(dest)

          File.write!(Path.join(dest, avatar_url), image)

          assign(socket,
            image_url: Routes.static_path(socket, "/avatars/#{user_id}/#{avatar_url}")
          )
      end

    {:ok, assign(socket, assigns)}
  end
end
