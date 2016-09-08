use Mix.Config
config :bus,
        host: 'localhost',
        port: 1883,
        client_id: "1", #needs to be string.
        keep_alive: 0, #this is in seconds.
        username: "admin@admin.com",
        password: "password123",
        auto_reconnect: true, #if client get disconnected, it will auto reconnect.
        auto_connect: true, #this will make sure when you start :bus process, it gets connected autometically
        callback: Bus.Callback #callback module, you need to implement callback inside.
