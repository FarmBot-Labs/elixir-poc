defmodule BotStatus do
  use GenServer
  def init(_) do
    initial_status = %{X: 0, Y: 0, Z: 0, S: 10, BUSY: true, LAST: "", PINS: Map.new }
    { :ok, initial_status }
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_status do
    GenServer.call(__MODULE__, {:get_status})
  end

  def handle_call({:get_status}, _from, status) do
    {:reply, status, status}
  end

  def handle_call({:get_pin, pin}, _from, status) do
    all_pins = Map.get(status, :PIN)
    got_pin = Map.get(all_pins, pin)
    {:reply, got_pin, status}
  end

  def handle_cast({:set_pin, pin, value}, current_status)  do
    current_pin_status = Map.get(current_status, :PINS)
    new_pin_status = Map.put(current_pin_status, pin, value)
    {:noreply, Map.update(current_status, :PINS, new_pin_status, fn _x -> new_pin_status end)}
  end

  def handle_cast({:set_busy, b}, current_status ) when is_boolean b do
    {:noreply, Map.update(current_status, :BUSY, b, fn _x ->  b end)}
  end

  def set_pin(pin, :on) when is_integer pin do
    GenServer.cast(__MODULE__, {:set_pin, pin, :on})
  end

  def set_pin(pin, :off) when is_integer pin do
    GenServer.cast(__MODULE__, {:set_pin, pin, :off})
  end

  def get_pin(pin) when is_integer pin do
    GenServer.call(__MODULE__, {:get_pin, pin})
  end

  def busy(b) when is_boolean b do
    GenServer.cast(__MODULE__, {:set_busy, b})
  end
  #
  # def set_pin(num, val) do
  #   val = [true, 1, '1'].include?(val) ? :on : :off
  #   transaction { |info| info.PINS[num] = val }
  # end
  #
  # def set_parameter(key, val) do
  #   transaction do |info|
  #     info[Gcode::PARAMETER_DICTIONARY.fetch(key,
  #       "UNKNOWN_PARAMETER_#{key}".to_sym)] = val
  # end
end
