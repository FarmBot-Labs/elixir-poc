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
  defp do_handle_event({:on_message_received, _topic, umessage}) do
    message = Poison.decode!(umessage)
    # Logger.debug "#{inspect(%{topic: topic, message: message})}"
    handle_serial({Map.get(message, "method"), Map.get(message, "params")})
  end

  # Successful connection event. Subscribe to our bot.
  defp do_handle_event({:on_connect, _data}) do
    Bus.Mqtt.subscribe(["bot/#{@uuid}/request"], [1])
  end

  # No real reason to print this but hey-oh
  defp do_handle_event({:on_subscribe, _data}) do
    Logger.debug "Subscribe Successful"
  end

  # Stub af. Thanks Elixir
  defp do_handle_event(event) do
    Logger.debug "UNHANDLED MQTT EVENT"
    IO.inspect(event)
  end


  defp handle_serial({"single_command.PIN WRITE", params}) do
    Logger.debug("PIN WRITE : #{inspect params}")
    SerialHandler.write_pin( Map.get(params, "pin"), Map.get(params, "value1"), Map.get(params, "mode") )

  end

  # MOVE RELATIVE X
  defp handle_serial({"single_command.MOVE RELATIVE",
                            %{"name" => "moveRelative",
                              "speed" => speed,
                              "x" => x } }) do
    Logger.debug("MOVE RELATIVE X: #{x} SPEED: #{speed}")
    SerialHandler.move_relative({:x, x}, speed)
  end

  # MOVE RELATIVE Y
  defp handle_serial({"single_command.MOVE RELATIVE",
                            %{"name" => "moveRelative",
                              "speed" => speed,
                              "y" => y } } ) do
    Logger.debug("MOVE RELATIVE Y #{y} SPEED: #{speed}")
    SerialHandler.move_relative({:y, y}, speed)
  end

  # MOVE RELATIVE Z
  defp handle_serial({"single_command.MOVE RELATIVE",
                            %{"name" => "moveRelative",
                              "speed" => speed,
                              "z" => z } }) do
    Logger.debug("MOVE RELATIVE Z: #{z} SPEED: #{speed}")
    SerialHandler.move_relative({:z, z}, speed)
  end

  # Possibly broke move relative command?
  defp handle_serial({"single_command.MOVE RELATIVE", params}) do
    Logger.debug("[broken?] MOVE RELATIVE : #{inspect params}")
  end

  defp handle_serial({"single_command.MOVE ABSOLUTE", params}) do
    Logger.debug("MOVE ABSOLUTE : #{inspect params}")
    # %{"speed" => 100, "x" => 5000, "y" => 192000, "z" => -13000}
    x = Map.get(params, "x")
    y = Map.get(params, "y")
    z = Map.get(params, "z")
    s = Map.get(params, "speed")
    SerialHandler.move_absolute(x,y,z,s)
  end

  # HOME ALL
  defp handle_serial({"single_command.HOME ALL", params}) do
    Logger.debug("HOME ALL : #{inspect params}")
    SerialHandler.home_all
  end

  # UNHANDLED SERIAL COMMAND
  defp handle_serial({method, params}) do
    Logger.debug("Unknown method: #{inspect method} with params: #{inspect params}")
  end
end
