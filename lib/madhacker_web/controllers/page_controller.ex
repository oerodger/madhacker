defmodule MadhackerWeb.PageController do
  use MadhackerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
