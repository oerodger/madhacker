defmodule Madhacker.UserActor do
  use GenServer

  def init(state), do: {:ok, state}

  def handle_cast(:hello, state) do
    MadhackerWeb.Endpoint.broadcast("user:#{ state.user_id }", "hello", %{})
    {:noreply, state}
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end
end
