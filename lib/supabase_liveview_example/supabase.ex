defmodule SupabaseLiveviewExample.Supabase do
  import Supabase
  import Postgrestex

  def get_connection() do
    Supabase.Connection.new(
      Application.fetch_env!(:supabase, :base_url),
      Application.fetch_env!(:supabase, :api_key)
    )
  end

  def fetch_profile(user_id, access_token) do
    Supabase.init(access_token: access_token)
    |> from("profiles")
    |> eq("id", user_id)
    |> call()
    |> json()
  end

  def fetch_public_profiles(access_token) do
    Supabase.init(access_token: access_token)
    |> from("profiles")
    |> call()
    |> json()
  end

  def update_profile(
        user_payload,
        access_token
      ) do
    Supabase.init(access_token: access_token)
    |> from("profiles")
    |> update(user_payload)
    |> call()
    |> json()
  end
end
