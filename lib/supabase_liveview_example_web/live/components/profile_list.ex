defmodule SupabaseLiveviewExampleWeb.Components.ProfileList do
  use SupabaseLiveviewExampleWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <h3 class="text-lg font-bold">Public Profiles</h3>
      <div class="py-4">
      <%= for profile <- @profiles do %>
      <div class="flex justify-between mt-4 p-4 border-grey-600 rounded-md border-2 bg-grey-700 bg-opacity-70">
        <%= live_component @socket, SupabaseLiveviewExampleWeb.Components.Avatar, avatar_url: profile["avatar_url"], user: @user %>
        <div class="self-center">
          <p class="text-xl font-bold mb-1"><%= profile["username"] %></p>
          <a class="text-green-400 text-sm opacity-80" target="_blank" href='<%= profile["website"] %>'><%= profile["website"] %></a>
          <p class="text-grey-200 text-sm">Last updated <%= format_date(profile["updated_at"]) %></p>
        </div>
      </div>
      <% end %>
      </div>
    """
  end

  defp format_date(date) do
    [date, _] = String.split(date, ".")
    String.replace(date, "T", " ")
  end
end
