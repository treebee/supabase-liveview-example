defmodule SupabaseLiveviewExampleWeb.PageLive do
  use SupabaseLiveviewExampleWeb, :live_view

  @impl true
  def render(assigns) do
    ~L"""
    <div class="container mx-auto pt-8 pb-16 max-w-5xl grid grid-cols-2 xs:grid-cols-1 text-white gap-12">
      <div>
        <%= live_component @socket, SupabaseLiveviewExampleWeb.Components.Account, id: "account", user: @user, access_token: @access_token, uploads: @uploads, profile: @profile %>
      </div>
      <div>
        <%= live_component @socket, SupabaseLiveviewExampleWeb.Components.ProfileList, profiles: @profiles, user: @user %>
      </div>
    </div>
    """
  end

  defp allow_uploads(socket) do
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:avatar,
      accept: ~w(.jpg .jpeg .png),
      max_entries: 1,
      external: &prepare_upload/2
    )
  end

  @impl true
  def mount(
        _params,
        session,
        socket
      ) do
    access_token = Map.get(session, "access_token", Map.get(socket.assigns, :access_token))
    refresh_token = Map.get(session, "refresh_token", Map.get(socket.assigns, :refresh_token))
    socket = login(socket, %{"access_token" => access_token, "refresh_token" => refresh_token})
    {:ok, allow_uploads(socket)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    [updated_profile] =
      consume_uploaded_entries(socket, :avatar, fn %{} = meta, _entry ->
        profile =
          Map.put(socket.assigns.profile, "avatar_url", meta.config.key)
          |> Map.put("id", socket.assigns.user["id"])

        SupabaseLiveviewExample.Supabase.update_profile(profile, socket.assigns.access_token)
        profile
      end)

    {:ok, profiles} =
      SupabaseLiveviewExample.Supabase.fetch_public_profiles(socket.assigns.access_token)

    socket = assign(socket, profiles: profiles)
    {:noreply, update(socket, :profile, fn profile -> Map.merge(profile, updated_profile) end)}
  end

  @impl true
  def handle_event("logout", _params, socket) do
    {:noreply, logout(socket)}
  end

  @impl true
  def handle_event(
        "update_profile",
        %{"profile" => %{"username" => username, "website" => website}},
        socket
      ) do
    payload =
      socket.assigns.profile
      |> Map.put("username", username)
      |> Map.put("website", website)
      |> Map.put("id", socket.assigns.user["id"])

    SupabaseLiveviewExample.Supabase.update_profile(payload, socket.assigns.access_token)

    {:ok, profiles} =
      SupabaseLiveviewExample.Supabase.fetch_public_profiles(socket.assigns.access_token)

    {:noreply, assign(socket, profile: payload, profiles: profiles)}
  end

  defp prepare_upload(entry, socket) do
    bucket = "avatars"
    key = entry.client_name
    config = %{bucket: bucket, key: key, access_token: socket.assigns.access_token}

    meta = %{
      uploader: "Supabase",
      key: key,
      url: "#{Application.get_env(:supabase, :base_url)}/storage/v1/object/#{bucket}/#{key}",
      config: config
    }

    {:ok, meta, socket}
  end

  defp login(socket, %{"access_token" => access_token, "refresh_token" => refresh_token}) do
    case SupabaseLiveviewExample.Auth.token_valid?(access_token) do
      {:ok, user} ->
        {:ok, profiles} = SupabaseLiveviewExample.Supabase.fetch_public_profiles(access_token)
        {:ok, profile} = fetch_profile(user, access_token)

        assign(socket, :user, user)
        |> assign(:access_token, access_token)
        |> assign(:refresh_token, refresh_token)
        |> assign(:profiles, profiles)
        |> assign(:profile, profile)

      {:error, _error} ->
        logout(socket)
    end
  end

  defp logout(socket) do
    assign(socket, :user, nil)
    |> redirect(to: "/logout")
  end

  defp fetch_profile(%{"id" => user_id}, access_token) do
    case SupabaseLiveviewExample.Supabase.fetch_profile(user_id, access_token) do
      {:ok, []} -> {:ok, %{}}
      {:ok, [profile]} -> {:ok, profile}
    end
  end
end
