
defmodule SerialHandler do
  @moduledoc """
    SERIALS
  """
  def write_pin(pin, value, mode) do
    Nerves.UART.write( pid, "F41 P#{pin} V#{value} M#{mode}" )
  end

  def init(_) do
    {:ok, pid} = Nerves.UART.start_link
    Nerves.UART.open(pid, "/dev/ttyACM0", speed: 115200, active: true)
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
end
