defmodule GameScoring.Repo.Migrations.CreateStat do
  use Ecto.Migration

  def change do
    create table(:stats) do
      add :kills, :integer
      add :assists, :integer
      add :deaths, :integer
      add :player_id, :integer
      add :game_id, :integer
    end

    create index(:stats, [:player_id])
    create index(:stats, [:game_id])
  end
end
