
defmodule SerialHandler do
  @moduledoc """
    SERIALS
  """
  require Logger
  def write_pin(pin, value, mode) do
    Logger.debug("writing pin")
    Nerves.UART.write( pid, "F41 P#{pin} V#{value} M#{mode}\r\n" )
  end

  def move_absolute(x, y, z, _s) when x > 0 and y > 0 do
    Logger.debug("G00 X#{x} Y#{y} Z#{z}")
    Nerves.UART.write(pid, "G00 X#{x} Y#{y} Z#{z}\r\n")
  end

  # SO NO BREAKAGE
  def move_absolute(_x, _y, _z, _s) do
    #Logger.debug("G00 X#{x} Y#{y} Z#{z}")
    Logger.debug("X or Y is Zero!!!@")
  end

  # MOVE_RELATIVE X
  def move_relative({:x, x}, speed) do
    {x, speed}
  end

  # MOVE_RELATIVE Y
  def move_relative({:y, y}, speed) do
    {y, speed}
  end

  # MOVE_RELATIVE Z
  def move_relative({:z, z}, speed) do
    {z, speed}
  end

  def home_x do
    Nerves.UART.write(pid, "F11\r\n")
  end

  def home_y do
    Nerves.UART.write(pid, "F12\r\n")
  end

  def home_z do
    Nerves.UART.write(pid, "F13\r\n")
  end

  def home_all do
    Nerves.UART.write(pid, "G28\r\n")
  end

  # Read a pin 1 is digital, 0 is analog?
  def read_pin(pin, mode \\ 1) do
    Nerves.UART.write(pid,"F42 P#{pin} M#{mode}\r\n")
  end

  def read_status(num) do
    Nerves.UART.write(pid,"F31 P#{num}\r\n" )
  end

  def read_parameter(code) do
    Nerves.UART.write(pid, "F21 P#{code}\r\n" )
  end

  #
  # # Parameters are settings, which is not to be confused with status.
  # def read_parameter(num) do
  #   Nerves.UART.write(pid, "F21 P#{num}")
  # end
  #
  # def read_pin(pin, mode = :digital)
  #   unless [:analog, :digital].include?(mode)
  #     raise "Mode must be :analog or :digital"
  #   end
  #   write { "F42 P#{pin} M#{(mode == :digital) ? 0 : 1}" }
  # end
  #
  # def read_status(num)
  #   write { "F31 P#{num}" }
  # end
  #
  # def write_parameter(num, val)
  #   write { "F22 P#{num} V#{val}" }
  #   key = Gcode::PARAMETER_DICTIONARY.fetch(num, "UNKNOWN_PARAMETER_#{num}")
  #   bot.status.transaction { |i| i[key] = val }
  # end
  #
  # def write_pin(pin:, value:, mode:)
  #   write { "F41 P#{pin} V#{value} M#{mode}" }
  #   bot.status.set_pin(pin, value)
  # end
  #
  # def set_max_speed(axis, value)
  #   set_paramater_value(axis, value, 71, 72, 73)
  # end
  #
  # def set_acceleration(axis, value)
  #   set_paramater_value(axis, value, 41, 42, 43)
  # end
  #
  # def set_timeout(axis, value)
  #   set_paramater_value(axis, value, 11, 12, 13)
  # end
  #
  # def set_steps_per_mm(axis, value)
  #   raise "The Farmbot Arduino does not currently store a value for steps "\
  #         "per mm. Keep track of this information at the application level"
  # end
  #
  # def set_end_inversion(axis, value)
  #   set_paramater_value(axis, bool_to_int(value), 21, 22, 23)
  # end
  #
  # def set_motor_inversion(axis, value)
  #   set_paramater_value(axis, bool_to_int(value), 31, 32, 33)
  # end
  #
  # def set_negative_coordinates(axis, value)
  #   raise "Not yet implemented. TODO: This method."
  # end

  def init(_) do
    Logger.debug("Starting Serial@ /dev/ttyACM0")
    {:ok, pid} = Nerves.UART.start_link
    :ok = Nerves.UART.open(pid, "/dev/ttyACM0", speed: 115200, active: true)
    {:ok, pid}
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_info(_, state) do
     {:noreply, state}
  end

  def pid do
    GenServer.call(SerialHandler, {:get_state})
  end

  def boot_strap do
    read_pins
    read_parameters
  end

  def read_pins do
    read_pins(0)
  end

  def read_pins(p) when p > 12 do
    read_pin(p)
  end

  def read_pins(p) do
    read_pin(p)
    read_pins(p+1)
  end

  def read_parameters do
    Enum.each(r_par, fn code -> read_parameter(code) end)
  end

  defp r_par do
    [0,1,11,12,13,21,22,23,31,32,33,41,42,43,51,52,53, 61,62,63,71,72,73]
  end
end
