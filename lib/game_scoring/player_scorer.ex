defmodule GameScoring.PlayerScorer do

  import Ecto.Query
  alias Ecto.Multi

  alias GameScoring.{
    Stat,
    Repo,
    Score
  }

  def run(game_id, callback \\ nil) do
    Task.start_link(fn ->

      :global.trans {Scorer, self()}, fn ->
        score_players(game_id)

        if is_function(callback) do
          callback.()
        end
      end

    end)
  end

  def score_players(game_id) do
    query =
      from s in Stat,
      where: s.game_id == ^game_id,
      select: %{player_id: s.player_id, kills: s.kills, assists: s.assists, deaths: s.deaths}

    new_scores =
      query
      |> Repo.all()
      |> calculate_total_score()
      |> Map.new

    existing_scores = get_all_scores()

    existing_scores
    |> merge(new_scores)
    |> sort
    |> save
  end

  defp calculate_total_score(game_stats) do
    Enum.reduce(game_stats, [], fn %{player_id: player_id, kills: k, assists: a, deaths: d}, acc ->
      score = (k * 10) + (a * 5) - (d * 2)
      [{player_id, {:insert, score}} | acc]
    end)
  end

  defp merge(existing, new) do
    Map.merge(existing, new, fn _user_id, {_, s1, _}, {_, s2}  ->
      {:update, s1, s1.score + s2}
    end)
  end


  defp sort(scores) do
    mapper =
      fn
        {_, {:insert, score}} ->
          score
        {_, {:update, _, score}} ->
          score
      end

    Enum.sort_by(scores, mapper, &>=/2)
  end

  defp save(scores) do
    {_, multi} = Enum.reduce(scores, {0, Multi.new}, &multi_query/2)
    Repo.transaction(multi, timeout: :infinity)
  end

  defp get_all_scores do
    Score
    |> Repo.all
    |> Enum.map(fn s -> {s.player_id, {:update, s, 0}} end)
    |> Map.new
  end

  defp multi_query({_, {:update, score, new_score}}, {index, multi}) do
    changeset = Score.changeset(score, %{rank: index + 1, score: new_score})

    multi = Multi.update(multi, "update-score-#{score.id}", changeset)
    {index + 1, multi}
  end

  defp multi_query({player_id, {:insert, score}}, {index, multi}) do
    changeset = Score.changeset(%Score{}, %{
      rank: index + 1,
      score: score,
      player_id: player_id
    })

    multi = Multi.insert(multi, "insert-score-index-#{index}", changeset)
    {index + 1, multi}
  end
end
