defmodule MadhackerWeb.PageController do
  use Amnesia
  use Database
  use MadhackerWeb, :controller

  def index(conn, _params) do
    Amnesia.transaction do
      render(conn, "index.html")
    end

  end
end
