defmodule GameScoring.RankingQueue do
  @moduledoc """
  RankingQueue is a GenServer that receives requests to rank users
  """

  use GenServer

  alias GameScoring.{
    Score,
    Repo
  }

  import Ecto.Query
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def enqueue do
    GenServer.call(__MODULE__, :enqueue)
  end

  def trigger do
    GenServer.call(__MODULE__, :trigger)
  end

  def init do
    {:ok, false}
  end

  def handle_call(:enqueue, _from, _) do
    {:reply, :ok, true}
  end

  def handle_call(:trigger, _from, _should_rerank) do
    rerank()

    {:reply, :ok, false}
  end

  defp rerank do
    query =
      from s in Score,
      order_by: [desc: s.score]

    stream = Repo.stream(query)

    Repo.transaction fn ->
      stream
      |> Stream.with_index(1)
      |> Stream.each(&update_rank/1)
      |> Stream.run
    end

    Bench.print_time()
  end

  defp update_rank({score, rank}) do
    score
    |> Score.changeset(%{rank: rank})
    |> Repo.update!
  end
end
