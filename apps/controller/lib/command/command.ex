defmodule Command do
  @moduledoc """
    Big pattern matches r big
  """

  def write_pin(pin, value, mode) do
    SerialMessageManager.sync_notify( {:send, "F41 P#{pin} V#{value} M#{mode}"} )
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
