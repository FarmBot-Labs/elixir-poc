# Elixir/Nerves proof of CONCEPT
VERY MUCH A WORK IN PROGRESS/ PROOF OF CONCEPT IF YOU MANAGE TO FIND IT, PLS. IT IS NOT READY

# WHAT IS IT?
Ok, Heres the deal. There are currently two elixir "apps" here. Yes the names are not good. Come up with something better.  

## fw
pretty much nothing. It is just a stub for a Nerves application. (it actually works lul)

## controller
This is a psuedo port of farmbot-raspberrypi-controller. 

### mqtt
This is what handles the mqtt messages, and dirrects them accordingly.

### serial
This handles serial connection and dirrects them accordingly.

### command (the name here is inaccurate)
This handles incoming and outgoing 'commands' from serial and mqtt. I THINK serial and mqtt shouldn't ever talk directly to eachother?

### bot_status
This is basically the bot state.

### sequence
Still needs a ton of work. Almost zero error checking. Handles sequences. Tested with the "Test" button on the gui.


## What is working?
* Mqtt
* Serial
* Bot state

## What isn't working?
* token generation
* callibration
* end stop reporting
* syncing
* probably a bunch of other stuff
* tests (exUnit) < !!!!


## Partial working
* Sequences (wait, pin write, move absolute)
* Initial bootup. (pins work, initial params dont)


# WHY EVEN MAKE THIS?
We were having some cute segfaults. Probably solved but I really like Elixir, and It's just kind of fun.

# HOW CAN I RUN IT??????
* You will need an [MQTT Broker](https://github.com/farmbot/mqtt-gateway) running locally.
* Then you will need to have a development instance of [The API](https://github.com/farmbot/Farmbot-web-API) running locally.
* install [Elixir](http://elixir-lang.org/)

open a new terminal for the API
``` bash
git clone https://github.com/farmbot/Farmbot-web-API
cd Farmbot-web-API
bundle install
rake db:setup
MQTT_HOST=localhost rails S
```

now open a new terminal and start teh mqtt Broker
``` bash
git clone https://github.com/farmbot/mqtt-gateway
cd mqtt-gateway
npm install
WEB_API_URL=http://localhost:3000 npm start
```

Now clone this repo. and open a shell in it.
``` bash
git clone https://github.com/FarmBot-Labs/elixir-poc
cd elixir-poc/apps/controller
mix deps.get
iex -S mix
```

Now you will be in an interactive shell of the controller. It will look for a serial device (with our firmware on it) on /dev/ttyACM0  

... profit..?
