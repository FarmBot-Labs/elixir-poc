defmodule UartHandler do
  require Logger
  def init(_) do
    tty = "/dev/ttyACM0"
    baud = 115200
    active = true
    {:ok, pid} = Nerves.UART.start_link
    Nerves.UART.open(pid, tty, speed: baud, active: active)
    Nerves.UART.configure(pid, framing: {Nerves.UART.Framing.Line, separator: "\r\n"}, rx_framing_timeout: 500)
    {:ok, pid}
  end

  def start_link(_) do
    Logger.debug("Starting Nerves Uart")
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def nerves do
    GenServer.call(__MODULE__, {:get_state})
  end

  # UartHandler.connect("/dev/ttyACM0", 115200)
  def connect(tty, baud, active \\ true) do
    GenServer.cast(__MODULE__, {:connect, tty, baud, active})
  end

  def send(str) do
    GenServer.cast(__MODULE__, {:send, str})
  end

  # Genserver Calls
  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:connect, tty, baud, active}, state) do
    Nerves.UART.open(state, tty, speed: baud, active: active)
    Nerves.UART.configure(state, framing: {Nerves.UART.Framing.Line, separator: "\r\n"}, rx_framing_timeout: 500)
    {:noreply, state}
  end

  def handle_cast({:send, str}, state) do
    Nerves.UART.write(state, str)
    {:noreply, state}
  end

  def handle_info({:nerves_uart, _tty, message}, state) do
    SerialMessageManager.sync_notify({:serial_message, message})
    {:noreply, state}
  end

  def handle_info(event, state) do
    Logger.debug "info: #{inspect event}"
    {:noreply, state}
  end
end
