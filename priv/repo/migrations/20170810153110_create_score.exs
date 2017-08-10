defmodule GameScoring.Repo.Migrations.CreateScore do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :player_id, :integer
      add :rank, :integer
      add :score, :float
    end

  end
end
