defmodule SupabaseLiveviewExampleWeb.LoginController do
  import Plug.Conn
  use SupabaseLiveviewExampleWeb, :controller

  def session(conn, %{"access_token" => access_token, "refresh_token" => refresh_token} = params) do
    IO.inspect(params)

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
end
