defmodule Bench do
  @game_count 50

  alias GameScoring.{
    Repo,
    Stat,
    Score,
    PlayerScorer
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
      PlayerScorer.run(game_id, fn -> IO.inspect game_id; update_timer() end)
    end

    :ok
  end


  defp random_stats_for_game(i) do
    players_per_game = 5

    for j <- 1..players_per_game do
      %{player_id: ((i - 1) * players_per_game) + j, game_id: i, kills: random(), assists: random(), deaths: random()}
    end
  end

  defp random do
    Enum.random(1..10)
  end

  def start_timer do
    Agent.start_link(fn -> %{start_time: System.monotonic_time(:millisecond), elapsed: nil, count: 0} end, name: __MODULE__)
  end

  def elapsed_time do
    elapsed = Agent.get(__MODULE__, fn %{elapsed: elapsed} ->
      elapsed
    end)
    Agent.stop(__MODULE__)
    elapsed
  end

  def tracked_count do
    Agent.get(__MODULE__, fn %{count: count} ->
      count
    end)
  end

  def update_timer do
    Agent.update(__MODULE__, fn state ->
      %{state | elapsed: (System.monotonic_time(:millisecond) - state.start_time), count: state.count + 1}
    end)

    if tracked_count() == @game_count do
      IO.inspect "Elapsed time: #{elapsed_time()}"
    end
  end
end
