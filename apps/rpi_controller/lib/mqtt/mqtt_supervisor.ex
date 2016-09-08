alias Experimental.{GenStage}
defmodule MqttSupervisor do
  @uuid Application.get_env(:mqtt, :uuid)
  @moduledoc """
    The main application for handling MQTT messages
  """
  def start do
    import Supervisor.Spec
    {:ok, _pid} = Bus.start(:normal, [])
    Bus.Mqtt.subscribe(["bot/#{uuid}/request"], [1])
    children = [
      # Should only be one of these
      worker(MqttMessageManager, []),
      # Unlimited number of Mqtt Message Handlers for the
      worker(MqttMessageHandler, [], id: 1)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
