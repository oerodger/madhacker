defmodule MadhackerWeb.PageController do
  use Amnesia
  use Database
  use MadhackerWeb, :controller

  def index(conn, _params) do
    Amnesia.transaction do
      ## john = %User{name: "John", email: "john@example.com"} |> User.write
      john = User.read(1)

      render(conn, "index.html", user: john.email)
    end

  end
end
