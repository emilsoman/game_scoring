defmodule GameScoring.Router do
  use GameScoring.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GameScoring do
    pipe_through :api
  end
end
