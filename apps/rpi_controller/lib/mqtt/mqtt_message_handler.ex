alias Experimental.{GenStage}
defmodule MqttMessageHandler do
  require IEx
  @moduledoc """
    This is the 'consumer'. It subscribes to MqttMessageManager, and just grabs
    messages as they come in. There can be many instances of this module.
  """
  use GenStage
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [MqttMessageManager]}
  end

  @doc """
    This is wher the messages come in.
  """
  def handle_events(events, _from, state) do
    for event <- events do
      do_handle_event(event)
    end
    {:noreply, [], state}
  end

  # Pattern match the incoming event.
  # As a side note, I think implementing the on_publish event to publish a
  # "ack" response type event would cause a hilarious infinate recursion
  # problem, and probably an API or Broker stack overflow.

  # This bot has received a message.
  # Will probably get broken out to another GenEvent for serial events?
  defp do_handle_event({:on_message_received, topic, umessage}) do
    message = Poison.decode!(umessage)
    # Logger.debug "#{inspect(%{topic: topic, message: message})}"
    handle_serial({Map.get(message, "method"), Map.get(message, "params")})
  end

  # Successful connection event. Subscribe to our bot.
  defp do_handle_event({:on_connect, _data}) do
    Bus.Mqtt.subscribe(["bot/58bea198-2468-4fee-9e91-1ef0b202fae1/request"], [1])
  end

  # No real reason to print this but hey-oh
  defp do_handle_event({:on_subscribe, _data}) do
    Logger.debug "Subscribe Successful"
  end

  # Stub af. Thanks Elixir
  defp do_handle_event(event) do
    Logger.debug "UNHANDLED EVENT"
    IO.inspect(event)
  end


  defp handle_serial({"single_command.PIN WRITE", params}) do
    Logger.debug("PIN WRITE : #{inspect params}")
    SerialHandler.write_pin( Map.get(params, "pin"), Map.get(params, "value1"), Map.get(params, "mode") )

  end

  defp handle_serial({"single_command.MOVE RELATIVE", params}) do
    Logger.debug("MOVE RELATIVE : #{inspect params}")
  end

  defp handle_serial({method, params}) do
    Logger.debug("Unknown method: #{inspect method} with params: #{inspect params}")
  end
end
