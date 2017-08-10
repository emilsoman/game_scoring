defmodule GameScoring.Score do
  use GameScoring.Web, :model

  schema "scores" do
    field :player_id, :integer
    field :rank, :integer
    field :score, :float
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:player_id, :rank, :score])
    |> validate_required([:player_id, :rank, :score])
  end
end
