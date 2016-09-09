alias Experimental.{GenStage}
defmodule SerialMessageHandler do
  @uuid Application.get_env(:mqtt, :uuid)
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

  def do_handle({:serial_message, "R00"}) do
    # Logger.debug("Heartbeat")
  end

  def do_handle({:serial_message, message}) do
    Logger.debug("Unhandled Serial Message/Gcode: #{inspect message}")
  end
end
