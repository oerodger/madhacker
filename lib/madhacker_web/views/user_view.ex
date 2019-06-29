defmodule MadhackerWeb.UserView do
  use MadhackerWeb, :view
  alias MadhackerWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{ name: user.name, token: user.token }
  end
end
