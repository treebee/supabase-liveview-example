defmodule SupabaseLiveviewExample.Supabase do
  def get_connection() do
    Supabase.Connection.new(
      Application.fetch_env!(:supabase, :base_url),
      Application.fetch_env!(:supabase, :api_key)
    )
  end

  def fetch_profile(user_id, access_token) do
    case get_connection()
         |> Supabase.Connection.get(
           "/rest/v1/profiles",
           params: [select: "username,website,avatar_url", id: "eq.#{user_id}"],
           headers: [auth_header(access_token)]
         ) do
      %Finch.Response{body: body, status: 200} -> {:ok, body}
      %Finch.Response{body: body} -> {:error, body}
    end
  end

  def fetch_public_profiles(access_token) do
    case get_connection()
         |> Supabase.Connection.get(
           "/rest/v1/profiles",
           headers: [auth_header(access_token)]
         ) do
      %Finch.Response{body: body, status: 200} -> {:ok, body}
      %Finch.Response{body: body} -> {:error, body}
    end
  end

  def update_profile(
        user_payload,
        access_token
      ) do
    case get_connection()
         |> Supabase.Connection.post(
           "/rest/v1/profiles",
           {:json, Map.put(user_payload, :updated_at, NaiveDateTime.utc_now())},
           [auth_header(access_token), {"prefer", "resolution=merge-duplicates"}]
         ) do
      %Finch.Response{status: 201} ->
        :ok

      resp ->
        IO.inspect(resp)
        :error
    end
  end

  defp auth_header(access_token) do
    {"Authorization", "Bearer #{access_token}"}
  end
end
