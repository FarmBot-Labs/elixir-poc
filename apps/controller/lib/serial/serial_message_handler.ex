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
      IO.inspect(event)
    end
    {:noreply, [], state}
  end
end
