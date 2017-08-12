defmodule Bench do
  @game_count 800
  @players_per_game 10

  alias GameScoring.{
    Repo,
    Stat,
    Score,
    ScoringQueue,
    RankingQueue
  }

  import Ecto.Query

  # 100 games with 5 players - 1.3 seconds
  # 100 games with 10 players - 2.3 seconds
  # 100 games with 40 players - 8.9 seconds
  # 100 games with 100 players - 25.8 seconds
  # 400 games with 10 players - 9.3 seconds
  # 800 games with 10 players - 19.8 seconds
  #
  # 1000 games with 10 players - 34.5 seconds (on server)
  # 3000 games with 10 players - 119.4 seconds (on server)
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
