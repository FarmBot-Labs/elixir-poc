alias Experimental.{GenStage}
defmodule MqttSupervisor do
  @moduledoc """
    The main application for handling MQTT messages
  """
  def start do
    import Supervisor.Spec
    {:ok, _pid} = Bus.start(:normal, [])
    Bus.Mqtt.subscribe(["bot/58bea198-2468-4fee-9e91-1ef0b202fae1/request"], [1])
    children = [
      # Should only be one of these
      worker(MqttMessageManager, []),
      # Unlimited number of Mqtt Message Handlers for the
      worker(MqttMessageHandler, [], id: 1)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
