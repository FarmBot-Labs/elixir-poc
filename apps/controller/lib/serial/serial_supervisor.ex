defmodule SerialSupervisor do
  @uuid Application.get_env(:mqtt, :uuid)
  @moduledoc """
    The main application for handling MQTT messages
  """
  def start_link(_args) do
    import Supervisor.Spec
    children = [
      worker(SerialMessageManager, []),
      worker(SerialMessageHandler, [], id: 1), # Consumer
      worker(UartHandler, [[]])
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def init(_) do
    {:ok, %{}}
  end
end
