defmodule MadhackerWeb.UserChannel do
  use Phoenix.Channel

  require Logger

  def join("user:" <> user_id, _params, socket) do
    {:ok, %{ "body" => "hello, " <> user_id }, assign(socket, :user_id, user_id)}
  end

  def handle_in("match:join", _message, socket) do
    Logger.debug("match join")
    if user_id = socket.assigns[:user_id] do
      Madhacker.MatchMaker.join(user_id)
      {:noreply, socket}
    else
      {:error, %{ "body" => "user_id is not associated" }}
    end
  end

  def handle_in("game:command", message, socket) do
    if user_id = socket.assigns[:user_id] do
      {:reply, %{ result: Madhacker.GameSupervisor.send(socket.game_id, user_id, message) }, socket}
    else
      {:error, %{ "body" => "user_id is not associated" }}
    end
  end
end
