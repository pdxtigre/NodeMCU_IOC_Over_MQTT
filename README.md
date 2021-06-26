# nodemcu-ioc-over-mqtt
IO control over MQTT with NodeMCU

## Introduction
This is one of my projects that I use *[NodeMCU](https://nodemcu.com)* development board to control my sprinkler system.  NodeMCU's are very popular and used widely in making IoT applications due to WiFi-enabled, small-form-factor, low-power-consumption, low-cost and easy-to-work-with characteristics.  

<img src="/docs/images/ESP-12E-ESP8266-pinout-diagram.jpg" width="400" title="NodeMCU ESP8266"/>

In this application, I use the specific model ESP-12E with ESP8266 that you can buy on Amazon for less than $5 a piece.  The choice of using the node modules with the target hardware as an RTU rather than using a Raspberry Pi is straight forward.  The Pi itself works best at the middle tier to control and collect the data from/to the nodes and provide a higher level of interface via web or other smart-home interfaces like Apple HomeKit, Amazon Alexa, or Google Assitant.

The node modules are used to control directly the sprinkler valves or get the input signal from the sensors such as soil moisture or rain sensors.  The nodes communicate with the Raspberry Pi over MQTT.  In general, we maintain 3 channels (topics):
- `cmd` Control channel for the incoming contorl command from the Raspberry Pi.
- `notif` Notification channel for the outgoing sensor updates from the node module.
- `status` Status channel for periodical status updates like heartbeart from the node module.

The MQTT broker could reside on the Raspberry Pi or on a separate server using *[HiveMQ](https://www.hivemq.com/)* or *[Mosquitto](https://mosquitto.org/)*

![Home Automation System Overview](/docs/images/home-automation-system.png)

## Configuration
The device config is stored in `config.lua` file with general device information and separate sections for specific purposes.  The file also contains a minimum set of helper functions to retrieve the config, a try/catch handler, and the logging method for debugging.

```lua
dev_cfg={
	id="ESP8266.Shadow",
	dob="04/18/2021",
	rev="3",
	app="mqtt_ioc",
  ...
	bootTime={sec=0, usec=0, rate=0},
	debug=true,
	start=true,
	heartbeat={
		enabled=true,
		interval=5000,
		ts={sec=0, usec=0, rate=0}
	}
  ...
}
```

### WiFi Credentials
```lua
	wifi={
		ssid= "<your WiFi SSID>",
		pwd= "<your WiFi password>"
	}
```  

### Signal List
Specify the inputs and outputs for your node module.
```lua
	io={
		digital=
		{	outputs = {
				D0={pin=0},
				D1={pin=1},
				D2={pin=2},
				D3={pin=3},
				D4={pin=4},
				D5={pin=5},
				D6={pin=6},
				D7={pin=7}
			},
			inputs = {}
		}
	}
```

### MQTT
Specify the MQTT endpoint setup
```lua
        mqtt={
		host="TheShadowsHouse.IoT",
		port=1883,
		topics={
			cmd="/TheShadowsHouse/IoT/cmd",
			notif="/TheShadowsHouse/IoT/notif",
			status="/TheShadowsHouse/IoT/status",
		}
	},
```

## Firmware
You can opt to use the NodeMCU online firmware builder or build your own firmware on your local computer.

### Online NodeMCU Custom Builds Using Cloud Build Service
Visit *[nodemcu-build](https://nodemcu-build.com/)*

### Local NodeMCU Builds with Docker Image
Visit *[marcelstoer/nodemcu-build](https://hub.docker.com/r/marcelstoer/nodemcu-build/)*

### Other Firmware Build Information
Visit *[Building the Firmware](https://nodemcu.readthedocs.io/en/dev/build/)*

## Downloading/Uploading Lua Code to Your ESP8266 Module
My two favorite tools are *[NodeMCU-Tool by Andi Dittrich](https://github.com/andidittrich/NodeMCU-Tool)* and *[ESPlorer by 4refr0nt](https://github.com/4refr0nt/ESPlorer)*.  The first one is the main code upload tool while the latter is used mainly for troubleshooting and debugging.

## Key Notes to Optimize Lua Code Execution, Memory Footprint on the ESP
- Use compiled code `.lc` in the node module instead of the raw `.lua` code.
- Eliminate all usage of the global variables except the global config; avoid upvalues to help garbage collecting.
- Adopt the flash function technique to serialize the in-memory functions into flash-based functions to reduce the heap usage.

### References
#### Code optimization and techniques for Reducing RAM and SPIFFS footprint
- *[How do I minimise the footprint of running application?](https://nodemcu.readthedocs.io/en/dev/lua-developer-faq/)*
- *[MASSIVE MEMORY OPTIMIZATION: FLASH FUNCTIONS! (+SPI SSD1306) (DP Whittaker)](https://www.esp8266.com/viewtopic.php?f=19&t=1940)*
