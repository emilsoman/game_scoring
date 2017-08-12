defmodule GameScoring.Scorer do
  import Ecto.Query

  alias GameScoring.{
    Repo,
    ScoringQueue,
    PlayerScorer,
    Stat
  }

  def start_link do
    flow =
      ScoringQueue
      |> Flow.from_stage
      |> Flow.flat_map(&get_player_ids/1)
      |> Flow.partition
      |> Flow.map(&PlayerScorer.score_player/1)
      |> Flow.map(&PlayerScorer.save_score/1)
      |> Flow.each(fn _ -> Bench.update_count() end)

    Flow.start_link(flow)
  end

  defp get_player_ids(game_id) do
    query =
      from s in Stat,
      where: s.game_id == ^game_id,
      select: s.player_id,
      distinct: true

    Repo.all(query)
  end
end
