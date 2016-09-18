defmodule Controller do
  # use Application
  require Logger
  require IEx

  @mqttport  Application.get_env(:bus, :port )
  @mqttid    Application.get_env(:bus, :client_id )
  @mqttka    Application.get_env(:bus, :keep_alive )
  @mqttar    Application.get_env(:bus, :auto_reconnect )
  @mqttac    Application.get_env(:bus, :auto_connect )
  @mqttcb    Application.get_env(:bus, :callback )

  @user Application.get_env(:fb, :user)
  @pass Application.get_env(:fb, :pass)
  def start(type, _args) do
    import Supervisor.Spec, warn: false
    Logger.debug("Starting Controller")
    children = [
      worker(BotStatus, [[]]),
      worker(Auth, ["admin@admin.com", "password123"]),
      supervisor(MqttSupervisor, [[]]),
      supervisor(SerialSupervisor, [[]]),
      supervisor(CommandSupervisor, [[]]),
      supervisor(SequenceSupervisor, [[]])
    ]
    opts = [strategy: :one_for_one, name: Controller.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)
    token = Map.get(Auth.get_token, :token)

    # I DON'T KNOW WHO YOU ARE OR WHY YOU MADE YOUR APP LIKE THIS BUT STOP
    Logger.debug("Setting environment??")
    Application.put_env(:bus, :host,           String.to_charlist(Map.get(token, "unencoded") |> Map.get("mqtt") ) )
    Application.put_env(:bus, :port,           @mqttport )
    Application.put_env(:bus, :client_id,      @mqttid   )
    Application.put_env(:bus, :keep_alive,     @mqttka   )
    Application.put_env(:bus, :username,       Map.get(token, "unencoded") |> Map.get("bot"))
    Application.put_env(:bus, :password,       Map.get(token, "encoded")   )
    Application.put_env(:bus, :auto_reconnect, @mqttar   )
    Application.put_env(:bus, :auto_connect,   @mqttac   )
    Application.put_env(:bus, :callback,       @mqttcb   )
    Bus.start(:normal, [])
    {:ok, sup}
  end
end
