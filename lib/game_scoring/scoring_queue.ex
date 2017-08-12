defmodule GameScoring.ScoringQueue do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def push(game_id) do
    GenStage.call(__MODULE__, {:push, game_id})
  end

  def init(nil) do
    {:producer, {[], 0}}
  end

  def handle_call({:push, game_id}, _from, {game_ids, demand}) do
    game_ids = [game_id | game_ids]

    {dispatch, state} = dispatch({game_ids, demand})
    {:reply, :ok, dispatch, state}
  end

  def handle_demand(demand, {game_ids, existing_demand}) when demand > 0 do
    {dispatch, state} = dispatch({game_ids, demand + existing_demand})
    {:noreply, dispatch, state}
  end

  defp dispatch({[], _} = state) do
    {[], state}
  end

  defp dispatch({game_ids, demand}) do
    {dispatch, rest} = Enum.split(game_ids, demand)
    new_state = {rest, demand - length(dispatch)}
    {dispatch, new_state}
  end
end
