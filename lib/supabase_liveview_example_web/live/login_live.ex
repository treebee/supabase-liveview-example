defmodule SupabaseLiveviewExampleWeb.LoginLive do
  use SupabaseLiveviewExampleWeb, :live_view

  @defaults %{
    email_input: "",
    email_msg: ""
  }
  @impl true
  def render(assigns) do
    ~L"""
    <div phx-hook="Session" id="session-container"></div>
    <div class="container mx-auto pt-8 pb-16 max-w-5xl grid grid-cols-2 xs:grid-cols-1 text-white gap-12">
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
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, @defaults) |> try_login(session)}
  end

  @impl true
  def handle_event("send_magic_link", %{"user" => %{"email" => email}}, socket) do
    SupabaseLiveviewExample.Auth.login_via_magic_link(email)
    {:noreply, assign(socket, email_input: "", email_msg: "Check your emails for a magic link.")}
  end

  @impl true
  def handle_event("update_email_input", %{"user" => %{"email" => email}}, socket) do
    {:noreply, assign(socket, email_input: email)}
  end

  @impl true
  def handle_event(
        "login",
        %{"access_token" => _access_token, "refresh_token" => _refresh_token} = params,
        socket
      ) do
    {:noreply, try_login(socket, params)}
  end

  defp try_login(socket, %{"access_token" => access_token, "refresh_token" => refresh_token}) do
    case SupabaseLiveviewExample.Auth.token_valid?(access_token) do
      {:ok, user} ->
        assign(socket, :user, user)
        |> assign(:access_token, access_token)
        |> assign(:refresh_token, refresh_token)
        |> redirect(to: "/profile")

      {:error, _error} ->
        socket
    end
  end

  defp try_login(socket, _params), do: socket
end
