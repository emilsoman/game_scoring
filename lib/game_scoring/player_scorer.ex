defmodule GameScoring.PlayerScorer do

  import Ecto.Query

  alias GameScoring.{
    Stat,
    Repo,
    Score
  }

  def score_player(player_id) do
    query =
      from s in Stat,
      where: s.player_id == ^player_id

    score =
      query
      |> Repo.all
      |> Flow.from_enumerable
      |> Flow.map(&calculate_score/1)
      |> Enum.sum

    {player_id, score}
  end

  def save_score({player_id, score}) do
    case Repo.get_by(Score, player_id: player_id) do
      nil  -> %Score{player_id: player_id}
      s -> s
    end
    |> Score.changeset(%{score: score})
    |> Repo.insert_or_update!
  end

  defp calculate_score(%{kills: k, assists: a, deaths: d}) do
    (k * 10) + (a * 5) - (d * 2)
  end
end
