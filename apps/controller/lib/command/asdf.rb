# !!!!!!!!!!THESE ALL NEED TO BE IMPLEMENTED AS COMMANDS!!!!!!!!!!!!

def emergency_stop(*)
  # This message is special- it is the only method that bypasses the queue.
  bot.outbound_queue = []  # Dump pending commands.
  bot.serial_port.puts "E" # Don't queue this one- write to serial line.
  bot.status[:last] = :emergency_stop
end

def move_relative(x: 0, y: 0, z: 0, s: 100)
  write do
    # REMEBER: YOU NEVER WANT TO MUTATE VARIABLES HERE. If you mutate vars
    # in a block, it will result in the return value getting incremented
    # every time the value is read. For this reason, we use ||= and not =.
    x1 ||= [(bot.current_position.x + (x || 0)), 0].max
    y1 ||= [(bot.current_position.y + (y || 0)), 0].max
    z1 ||= (bot.current_position.z + (z || 0)) || 0

    "G00 X#{x1} Y#{y1} Z#{z1}"
  end
end

def move_absolute(x: 0, y: 0, z: 0, s: 100)
  x = [x.to_i, 0].max
  y = [y.to_i, 0].max
  z = z.to_i || 0
  write { "G00 X#{x} Y#{y} Z#{z}" }
end

def home_x
  write { "F11" }
end

def home_y
  write { "F12" }
end

def home_z
  write { "F13" }
end

def home_all
  write { "G28" }
end

# Parameters are settings, which is not to be confused with status.
def read_parameter(num)
  write { "F21 P#{num}" }
end

def read_pin(pin, mode = :digital)
  unless [:analog, :digital].include?(mode)
    raise "Mode must be :analog or :digital"
  end
  write { "F42 P#{pin} M#{(mode == :digital) ? 0 : 1}" }
end

def read_status(num)
  write { "F31 P#{num}" }
end

def write_parameter(num, val)
  write { "F22 P#{num} V#{val}" }
  key = Gcode::PARAMETER_DICTIONARY.fetch(num, "UNKNOWN_PARAMETER_#{num}")
  bot.status.transaction { |i| i[key] = val }
end

def write_pin(pin:, value:, mode:)
  write { "F41 P#{pin} V#{value} M#{mode}" }
  bot.status.set_pin(pin, value)
end

def set_max_speed(axis, value)
  set_paramater_value(axis, value, 71, 72, 73)
end

def set_acceleration(axis, value)
  set_paramater_value(axis, value, 41, 42, 43)
end

def set_timeout(axis, value)
  set_paramater_value(axis, value, 11, 12, 13)
end

def set_steps_per_mm(axis, value)
  raise "The Farmbot Arduino does not currently store a value for steps "\
        "per mm. Keep track of this information at the application level"
end

def set_end_inversion(axis, value)
  set_paramater_value(axis, bool_to_int(value), 21, 22, 23)
end

def set_motor_inversion(axis, value)
  set_paramater_value(axis, bool_to_int(value), 31, 32, 33)
end

def set_negative_coordinates(axis, value)
  raise "Not yet implemented. TODO: This method."
end
