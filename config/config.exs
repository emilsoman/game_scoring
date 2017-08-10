# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :game_scoring,
  ecto_repos: [GameScoring.Repo]

# Configures the endpoint
config :game_scoring, GameScoring.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DDrV04kKpToxUd8Ro/3W58Gbx4/Tw9jOdv9hXcT2QMeRS7dOiZxzfGAitEVTtyEl",
  render_errors: [view: GameScoring.ErrorView, accepts: ~w(json)],
  pubsub: [name: GameScoring.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
