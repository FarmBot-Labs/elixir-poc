use Mix.Config
config :bus,
        host: 'localhost',
        port: 1883,
        client_id: "1", #needs to be string.
        keep_alive: 0, #this is in seconds.
        username: "admin@admin.com", # This will need to be a uuid
        password: "password123", # This will need to be a token.
        auto_reconnect: true, #if client get disconnected, it will auto reconnect.
        auto_connect: true, #this will make sure when you start :bus process, it gets connected autometically
        callback: Bus.Callback #callback module, you need to implement callback inside.

config :mqtt,
        # THIS WILL NOT WORK ON YOUR MUSHEEN!!!!!!!!!!!!!!!!
        # YOU NEED TO GET UR OWN UUID!!!!!!!!!!!
        uuid: "7652fc7a-8d23-4c54-95ae-236717d1d4aa"
config :uart,
        tty: "/dev/ttyACM0",
        baud: 115200
