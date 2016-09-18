use Mix.Config
config :bus,
  port: 1883,
  client_id: "FARMBOT_DEVELOPMENT", #needs to be string.
  keep_alive: 0, #this is in seconds.
  auto_reconnect: true, #if client get disconnected, it will auto reconnect.
  auto_connect: true, #this will make sure when you start :bus process, it gets connected autometically
  callback: Mqtt.Callback #callback module, you need to implement callback inside.

config :uart,
  tty:  "/dev/ttyACM0",
  baud: 115200

config :fb,
  user: "admin@admin.com",
  pass: "password123"

config :nerves,
  ro_path: "config"
