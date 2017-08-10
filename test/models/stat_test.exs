defmodule GameScoring.StatTest do
  use GameScoring.ModelCase

  alias GameScoring.Stat

  @valid_attrs %{assists: 42, deaths: 42, kills: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Stat.changeset(%Stat{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Stat.changeset(%Stat{}, @invalid_attrs)
    refute changeset.valid?
  end
end
