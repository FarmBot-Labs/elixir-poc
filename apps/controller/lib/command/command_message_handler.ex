alias Experimental.{GenStage}
defmodule CommandMessageHandler do
  @uuid Application.get_env(:mqtt, :uuid)
  require IEx
  use GenStage
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [CommandMessageManager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      do_handle(event)
    end
    {:noreply, [], state}
  end

  def do_handle({"single_command.PIN WRITE", %{"mode" => m, "pin" => p, "value1" => v}}) do
    Command.write_pin(p,v,m)
  end

  def do_handle({"single_command.MOVE ABSOLUTE", %{"speed" => s, "x" => x, "y" => y, "z" => z}}) do
    Command.move_absolute(x,y,z,s)
  end

  def do_handle(event) do
    Logger.debug("Unhandled Event: #{inspect event}")
  end
end
