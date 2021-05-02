defmodule SupabaseLiveviewExampleWeb.LoginController do
  import Plug.Conn
  use SupabaseLiveviewExampleWeb, :controller

  def index(conn, params) do
    IO.inspect(params)

    case Plug.Conn.get_session(conn, "refresh_token") do
      nil ->
        IO.puts("index.html")
        render(conn, "index.html")

      token ->
        case SupabaseLiveviewExample.Supabase.get_connection()
             |> Supabase.Auth.GoTrue.refresh_access_token(token) do
          {:ok, body} ->
            IO.inspect(body)
            redirect_to_page(conn, body)

          {:error, _error} ->
            conn |> clear_session() |> redirect(to: "/login")
        end
    end
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    {:ok, body} =
      SupabaseLiveviewExample.Supabase.get_connection()
      |> Supabase.Auth.GoTrue.sign_in(email, password)
      |> IO.inspect()

    redirect_to_page(conn, body)
  end

  def session(conn, %{"access_token" => access_token, "refresh_token" => refresh_token} = params) do
    IO.inspect(params)
    # supabase = SupabaseLiveviewExample.Supabase.get_connection()
    # Supabase.Auth.GoTrue.send_magic_link_email(supabase, params["user"]["email"])
    # conn |> redirect(to: "/login")
    conn
    |> put_session(:access_token, access_token)
    |> put_session(:refresh_token, refresh_token)
    |> json("ok")
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: "/")
  end

  defp redirect_to_page(conn, body) do
    conn
    |> put_session(:access_token, body["access_token"])
    |> put_session(:refresh_token, body["refresh_token"])
    |> put_session(:user_id, body["user"]["id"])
    |> redirect(to: "/")
  end
end
