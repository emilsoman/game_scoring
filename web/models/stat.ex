defmodule GameScoring.Stat do
  use GameScoring.Web, :model

  schema "stats" do
    field :kills, :integer
    field :assists, :integer
    field :deaths, :integer
    field :player_id, :integer
    field :game_id, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:kills, :assists, :deaths])
    |> validate_required([:kills, :assists, :deaths])
  end
end
