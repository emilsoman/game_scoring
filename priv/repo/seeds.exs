# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GameScoring.Repo.insert!(%GameScoring.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule Seeds do
  def seed_scores do
    for i <- 0..100 do
      GameScoring.Repo.insert_all(GameScoring.Stat, random_stats_for_game(i))
    end
  end

  defp random_stats_for_game(i) do
    for j <- 1..500 do
      %{player_id: (i * 500) + j, game_id: i, kills: random(), assists: random(), deaths: random()}
    end
  end

  defp random do
    Enum.random(1..10)
  end
end

Seeds.seed_scores()
