defmodule Bench do
  @game_count 100
  @players_per_game 40

  alias GameScoring.{
    Repo,
    Stat,
    Score,
    PlayerScorer
  }

  import Ecto.Query

  # Results
  # 100 games with 10 players - 45.4 seconds
  # 100 games with 40 players - ___
  # 100 games with 100 players - 327.0 seconds
  # 400 games with 10 players - 444.7 seconds
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
      PlayerScorer.run(game_id, fn -> update_count() end)
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
    Agent.start_link(fn -> %{start_time: System.monotonic_time(:millisecond), count: 0} end, name: __MODULE__)
  end

  def update_count do
    {count, start_time} = Agent.get_and_update(__MODULE__, fn state ->
      new_count = state.count + 1
      state = %{state | count: new_count}
      {{new_count, state.start_time}, state}
    end)

    if count == @game_count do
      elapsed_time = System.monotonic_time(:millisecond) - start_time
      Agent.stop(__MODULE__)
      IO.inspect "Elapsed time: #{elapsed_time}"
    end
  end
end
