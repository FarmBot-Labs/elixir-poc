defmodule Command do
  require Logger
  @moduledoc """
    Big pattern matches r big
  """

  @doc """
    EMERGENCY STOP
  """
  def e_stop do
    Logger.info("E STOP")
    UartHandler.send("E") # Don't queue this one- write to serial line.
    BotStatus.set_last(:emergency_stop)
  end

  @doc """
    Home All
  """
  def home_all(_speed) do
    Logger.info("HOME ALL")
    BotStatus.set_pos(0,0,0) # I don't know if im supposed to do this?
    SerialMessageManager.sync_notify( {:send, "G28"} )
  end

  @doc """
    Home x
  """
  def home_x(_speed) do
    Logger.info("HOME X")
    SerialMessageManager.sync_notify( {:send, "F11"} )
  end

  @doc """
    Home y
  """
  def home_y(_speed) do
    Logger.info("HOME Y")
    SerialMessageManager.sync_notify( {:send, "F12"} )
  end

  @doc """
    Home z
  """
  def home_z(_speed) do
    Logger.info("HOME Z")
    SerialMessageManager.sync_notify( {:send, "F13"} )
  end

  @doc """
    Writes a pin high or low
  """
  def write_pin(pin, value, mode) do
    Logger.info("WRITE_PIN " <> "F41 P#{pin} V#{value} M#{mode}")
    SerialMessageManager.sync_notify( {:send, "F41 P#{pin} V#{value} M#{mode}"} )
  end

  @doc """
    Moves to (x,y,z) point
  """
  def move_absolute(x, y, z, _s) when x >= 0 and y >= 0 do
    Logger.info("MOVE_ABSOLUTE " <> "G00 X#{x} Y#{y} Z#{z}")
    SerialMessageManager.sync_notify( {:send, "G00 X#{x} Y#{y} Z#{z}"} )
    BotStatus.set_pos(x,y,z)
  end

  # there must be a better way to do this lol
  def move_absolute(x, y, z, s) when x <= 0 and y <= 0 do
    move_absolute(0,0,z,s)
  end

  # when x is negative
  def move_absolute(x, y, z, s) when x <= 0 do
    move_absolute(0,y,z,s)
  end

  # when y is negative
  def move_absolute(x, y, z, s) when y <= 0 do
    move_absolute(x,0,z,s)
  end

  def move_relative({:x, speed, move_by}) do
    [x,y,z] = BotStatus.get_current_pos
    move_absolute(x + move_by, y,z, speed)
  end

  def move_relative({:y, speed, move_by}) do
    [x,y,z] = BotStatus.get_current_pos
    move_absolute(x, y + move_by ,z, speed)
  end

  def move_relative({:z, speed, move_by}) do
    [x,y,z] = BotStatus.get_current_pos
    move_absolute(x, y, z + move_by, speed)
  end

  def read_status(id \\ nil) do
    current_status = BotStatus.get_status
    [x,y,z] = BotStatus.get_current_pos
    results = Map.merge(%{
      busy: 0,
      last: Map.get(current_status, :LAST),
      method: "read_status",
      s: Map.get(current_status, :S),
      x: x,
      y: y,
      z: z}, Map.get(current_status, :PARAMS)) |> Map.merge(Map.get(current_status, :PINS))

    message = %{id: id,
            error: nil,
            result: results}
    MqttMessageManager.sync_notify( {:emit, Poison.encode!(message)} )
  end
end
