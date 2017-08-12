defmodule Bench do
  @game_count 50
  @players_per_game 5

  alias GameScoring.{
    Repo,
    Stat,
    Score,
    ScoringQueue,
    RankingQueue
  }

  import Ecto.Query

  # V2 - 95 seconds
  def run do
    clear()
    create_games()
    score_games()
  end

  def clear do
    Repo.delete_all(Stat)
    Repo.delete_all(Score)
  end

  def create_games do
    for i <- 1..@game_count do
      Repo.insert_all(Stat, random_stats_for_game(i))
    end
  end

  def score_games do
    query =
      from s in Stat,
      select: s.game_id,
      distinct: true

    game_ids = Repo.all(query)
    start_timer()
    for game_id <- game_ids do
      ScoringQueue.push(game_id)
    end

    :ok
  end


  defp random_stats_for_game(i) do
    for j <- 1..@players_per_game do
      %{player_id: ((i - 1) * @players_per_game) + j, game_id: i, kills: random(), assists: random(), deaths: random()}
    end
  end

  defp random do
    Enum.random(1..10)
  end

  def start_timer do
    Agent.start_link(fn -> %{start_time: System.monotonic_time(:millisecond), elapsed: nil, count: 0} end, name: __MODULE__)
  end

  def update_count do
    count = Agent.get_and_update(__MODULE__, fn state ->
      new_count = state.count + 1
      {new_count, %{state | count: new_count}}
    end)

    if count == (@game_count * @players_per_game) do
      RankingQueue.trigger()
    end
  end

  def print_time do
    start_time = Agent.get(__MODULE__, fn %{start_time: start_time} ->
      start_time
    end)

    elapsed_time = System.monotonic_time(:millisecond) - start_time
    Agent.stop(__MODULE__)
    IO.inspect "Elapsed time: #{elapsed_time}"
  end
end
