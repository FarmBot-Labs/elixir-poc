defmodule Controller do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(BotStatus, [[]]),
      supervisor(MqttSupervisor, [[]]),
      supervisor(SerialSupervisor, [[]]),
      supervisor(CommandSupervisor, [[]]),
      supervisor(SequenceSupervisor, [[]])
    ]
    opts = [strategy: :one_for_one, name: Controller.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)
    {:ok, bus} = Bus.start(:a,:b)
    {:ok, sup}
  end
end
