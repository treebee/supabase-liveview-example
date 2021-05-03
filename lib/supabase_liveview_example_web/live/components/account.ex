defmodule SupabaseLiveviewExampleWeb.Components.Account do
  use SupabaseLiveviewExampleWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <h3 class="text-lg font-bold">Account</h3>
      <div class="py-4 mb-16">
        <label class="text-grey-500 text-xs uppercase">Avatar Image</label>
        <form id="upload-form" phx-submit="save" phx-change="validate">
          <div class="my-2">
            <%= for entry <- @uploads.avatar.entries do %>
            <%= live_img_preview entry, width: 80 %>
            <% end %>
            <%= live_file_input @uploads.avatar %>
          </div>
          <button type="submit" class="btn">upload</button>
        </form>
      </div>
      <div>
        <%= form_for :profile, "#", [phx_submit: :update_profile], fn f -> %>
        <div>
          <label for="email" class="uppercase text-grey-500 text-sm">email</label>
          <%= text_input f, :email, disabled: true, class: "form-input text-grey-500", value: Map.get(@user, "email") %>
        </div>
        <div class="mt-6">
          <label for="username" class="uppercase text-grey-500 text-sm">username</label>
          <%= text_input f, :username, class: "form-input", value: Map.get(@profile, "username") %>
        </div>
        <div class="mt-6">
          <label for="website" class="uppercase text-grey-500 text-sm">website</label>
          <%= text_input f, :website, class: "form-input", value: Map.get(@profile, "website") %>
        </div>
        <%= submit "update", class: "btn mt-6" %>
        <% end %>
        <button class="mt-6 btn-outlined" phx-click="logout">logout</button>
      </div>
    """
  end
end
