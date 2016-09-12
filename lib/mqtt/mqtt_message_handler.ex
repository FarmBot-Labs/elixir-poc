alias Experimental.{GenStage}
defmodule MqttMessageHandler do
  @uuid Application.get_env(:mqtt, :uuid)
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
    This is where the messages come in.
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
  defp do_handle_event({:on_message_received, _topic, umessage}) do
    message = Poison.decode!(umessage)
    # Logger.debug "#{inspect message}"
    CommandMessageManager.sync_notify(message)
  end

  # Successful connection event. Subscribe to our bot.
  defp do_handle_event({:on_connect, _data}) do
    Bus.Mqtt.subscribe(["bot/#{@uuid}/request"], [1])
  end

  defp do_handle_event({:on_publish, _stuff}) do
    nil
  end

  # No real reason to print this but hey-oh
  defp do_handle_event({:on_subscribe, _data}) do
    Logger.debug "Subscribe Successful"
  end

  # I think ill remove this?
  defp do_handle_event({:publish, topic, message, dup, qos, retain}) do
    Logger.debug("Publishing: #{topic}, #{message}, #{dup}, #{qos}, #{retain}")
    Bus.Message.publish(topic, message, dup, qos, retain)
  end

  defp do_handle_event({:emit, message}) do
    Bus.Mqtt.publish("bot/#{@uuid}/response", message)
  end

  # Stub af. Thanks Elixir
  defp do_handle_event(event) do
    Logger.debug "UNHANDLED MQTT EVENT"
    IO.inspect(event)
  end
end