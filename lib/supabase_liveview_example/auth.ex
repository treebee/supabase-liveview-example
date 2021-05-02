defmodule SupabaseLiveviewExample.Auth do
  def token_valid?(access_token) do
    supabase = SupabaseLiveviewExample.Supabase.get_connection()
    Supabase.Auth.GoTrue.user(supabase, access_token)
  end

  def login_via_magic_link(email) do
    SupabaseLiveviewExample.Supabase.get_connection()
    |> Supabase.Auth.GoTrue.send_magic_link_email(email)
  end
end
