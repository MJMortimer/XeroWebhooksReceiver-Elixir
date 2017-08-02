defmodule XeroWebhooksReceiver do
  use Application
  require Logger

  def start(_type, _args) do
    chilren = [
      Plug.Adapters.Cowboy.child_spec(:http, XeroWebhooksReceiver.Router, [], port: 5000)
    ]

    Logger.info "App Started!"

    Supervisor.start_link(chilren, strategy: :one_for_one)
  end
end