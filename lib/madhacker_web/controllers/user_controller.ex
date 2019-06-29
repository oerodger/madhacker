defmodule MadhackerWeb.UserController do
  use MadhackerWeb, :controller
  use Amnesia

  action_fallback MadhackerWeb.FallbackController

  def index(conn, %{"login" => login}) do
    user = Amnesia.transaction! do
      query = [name: login]
      Database.User.match(query)
    end
    [head | _] = Amnesia.Selection.values(user)
    render(conn, "user.json", user: head)
  end

  def new(conn, %{"login" => login}) do
    Amnesia.transaction do
      user = %Database.User{name: login, token: UUID.uuid1()} |> Database.User.write
      render(conn, "user.json", user: user)
    end
  end

end
