defmodule SupabaseLiveviewExampleWeb.PageLive do
  use SupabaseLiveviewExampleWeb, :live_view

  @impl true
  def render(assigns) do
    ~L"""
    <div phx-hook="Session" id="session-container"></div>
    <div class="container mx-auto pt-8 pb-16 max-w-5xl grid grid-cols-2 xs:grid-cols-1 text-white gap-12">
      <%= if @user do %>
        <div>
          <%= live_component @socket, SupabaseLiveviewExampleWeb.Components.Account, id: "account", user: @user, access_token: @access_token, uploads: @uploads, profile: @profile %>
        </div>
        <div>
          <%= live_component @socket, SupabaseLiveviewExampleWeb.Components.ProfileList, profiles: @profiles, user: @user %>
        </div>
      <% else %>
        <div>
          <h1 class="text-3xl font-bold">Supabase Auth + Storage for Phoenix LiveView</h1>
        </div>
        <div>
          <p>Sign in via magic link with your email below</p>
          <%= form_for :user, "#", [phx_submit: :send_magic_link, phx_change: :update_email_input], fn f -> %>
            <div class="mt-8 relative rounded-sm shadow-sm">
              <%= text_input f, :email, value: @email_input, class: "focus:ring-grey-100 focus:border-grey-100 border-2 border-grey-700 rounded-sm bg-background block w-full p-2 sm:text-sm border-gray-300 rounded-md", placeholder: "Your email" %>
              <%= submit "Send Magic Link", class: "uppercase focus:ring-grey-100 focus:border-grey-100 border-2 border-grey-700 rounded-sm bg-background block w-full p-2 sm:text-sm border-gray-300 rounded-md mt-4", placeholder: "Your email" %>
            </div>
          <% end %>
          <p><%= @email_msg %></p>
        </div>
      <% end %>
    </div>
    """
  end

  defp allow_uploads(socket) do
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)
  end

  @impl true
  def mount(
        _params,
        %{"access_token" => _access_token, "refresh_token" => _refresh_token} = session,
        socket
      ) do
    socket = login(socket, session)
    {:ok, allow_uploads(socket)}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, user: nil, profile: %{}, profiles: [], email_input: "", email_msg: "")
     |> allow_uploads()}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "login",
        %{"access_token" => _access_token, "refresh_token" => _refresh_token} = params,
        socket
      ) do
    socket = login(socket, params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("send_magic_link", %{"user" => %{"email" => email}}, socket) do
    SupabaseLiveviewExample.Auth.login_via_magic_link(email)
    # TODO give feedback
    {:noreply, assign(socket, email_input: "", email_msg: "Check your emails for a magic link.")}
  end

  @impl true
  def handle_event("update_email_input", %{"user" => %{"email" => email}}, socket) do
    {:noreply, assign(socket, email_input: email)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    [updated_profile] =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
        conn = SupabaseLiveviewExample.Supabase.get_connection()

        {:ok, _} =
          conn
          |> Supabase.Storage.Objects.create("avatars", entry.client_name, path,
            content_type: entry.client_type
          )

        profile =
          Map.put(socket.assigns.profile, "avatar_url", entry.client_name)
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
