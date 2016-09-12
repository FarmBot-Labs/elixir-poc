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

  # E STOP
  def do_handle(%{"method" => "single_command.EMERGENCY STOP", "params" => _, "id" => _id}) do
    Command.e_stop
  end

  def do_handle(%{"method" =>"single_command.HOME ALL", "params" => %{"name" => "homeAll", "speed" => s}, "id" => _id }) do
    Command.home_all(s)
  end

  # Write a pin
  def do_handle(%{"method" => "single_command.PIN WRITE", "params" => %{"mode" => m, "pin" => p, "value1" => v}, "id" => _id}) do
    Command.write_pin(p,v,m)
  end

  # Move to a specific coord
  def do_handle(%{"method" => "single_command.MOVE ABSOLUTE", "params" =>  %{"speed" => s, "x" => x, "y" => y, "z" => z}, "id" => _id}) do
    Command.move_absolute(x,y,z,s)
  end

  # I think this will work
  def do_handle(%{"method" => "single_command.MOVE RELATIVE", "params" =>  %{"name" => "moveRelative", "speed" => s, "x" => move_by}, "id" => _id}) do
    Command.move_relative({:x, s, move_by})
  end

  def do_handle(%{"method" => "single_command.MOVE RELATIVE", "params" => %{"name" => "moveRelative", "speed" => s, "y" => move_by}, "id" => _id}) do
    Command.move_relative({:y, s, move_by})
  end

  def do_handle(%{"method" => "single_command.MOVE RELATIVE", "params" => %{"name" => "moveRelative", "speed" => s, "z" => move_by}, "id" => _id}) do
    Command.move_relative({:z, s, move_by})
  end

  # Read status
  def do_handle(%{"method" => "read_status", "id" => id}) do
    Command.read_status(id)
  end

  # Unhandled event. Probably not implemented if it got this far.
  def do_handle(event) do
    Logger.debug("[command_handler] (Probably not implemented) Unhandled Event: #{inspect event}")
  end
end
