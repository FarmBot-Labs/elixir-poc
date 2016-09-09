defmodule Controller do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    SerialHandler.start_link
    MqttSupervisor.start
    SerialHandler.boot_strap
    children = []
    opts = [strategy: :one_for_one, name: Controller.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
