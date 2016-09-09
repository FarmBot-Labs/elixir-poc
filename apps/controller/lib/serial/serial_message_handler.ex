alias Experimental.{GenStage}
defmodule SerialMessageHandler do
  require IEx
  use GenStage
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [SerialMessageManager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      do_handle(event)
    end
    {:noreply, [], state}
  end

  def do_handle({:send, str}) do
    GenServer.cast(UartHandler, {:send, str})
  end

  def do_handle({:serial_message, {:idle} }) do
    BotStatus.busy false
  end

  def do_handle({:serial_message, {:done } }) do
    BotStatus.busy false
  end

  def do_handle({:serial_message, {:received } }) do
    BotStatus.busy true
  end

  # Unhandled gcode message
  def do_handle({:serial_message, {:unhandled_gcode, code}}) do
    Logger.debug("Broken code? : #{inspect code}")
  end

  def do_handle({:serial_message, message}) do
    Logger.debug("Unhandled Serial Gcode: #{inspect message}")
  end
end
