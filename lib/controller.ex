defmodule Controller do
  # use Application
  require Logger
  require IEx

  @mqtthost  Application.get_env(:bus, :host )
  @mqttport  Application.get_env(:bus, :port )
  @mqttid    Application.get_env(:bus, :client_id )
  @mqttka    Application.get_env(:bus, :keep_alive )
  @mqttun    Application.get_env(:bus, :username )
  @mqttpw    Application.get_env(:bus, :password )
  @mqttar    Application.get_env(:bus, :auto_reconnect )
  @mqttac    Application.get_env(:bus, :auto_connect )
  @mqttcb    Application.get_env(:bus, :callback )

  def start(type, args) do
    import Supervisor.Spec, warn: false
    Logger.debug("Starting Controller")
    Logger.debug("type: #{inspect type}")
    Logger.debug("args: #{inspect args}")
    children = [
      worker(BotStatus, [[]]),
      supervisor(MqttSupervisor, [[]]),
      supervisor(SerialSupervisor, [[]]),
      supervisor(CommandSupervisor, [[]]),
      supervisor(SequenceSupervisor, [[]])
    ]
    opts = [strategy: :one_for_one, name: Controller.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)

    # I DON'T KNOW WHO YOU ARE OR WHY YOU MADE YOUR APP LIKE THIS BUT STOP
    Logger.debug("Setting environment??")
    Application.put_env(:bus, :host,           @mqtthost )
    Application.put_env(:bus, :port,           @mqttport )
    Application.put_env(:bus, :client_id,      @mqttid   )
    Application.put_env(:bus, :keep_alive,     @mqttka   )
    Application.put_env(:bus, :username,       @mqttun   )
    Application.put_env(:bus, :password,       @mqttpw   )
    Application.put_env(:bus, :auto_reconnect, @mqttar   )
    Application.put_env(:bus, :auto_connect,   @mqttac   )
    Application.put_env(:bus, :callback,       @mqttcb   )
    {:ok, sup}
  end
end
