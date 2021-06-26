----------------------------------------
-- config.lua                         --
-- desc   : device configuration      --
-- rev    : 2.0                       --
-- date   : 04/27/2021                --
-- author : tuan nguyen (pdxtigre)    --
-- email  : info@codesmiths.org       --
-- website: https://codesmiths.org    --
----------------------------------------
dev_cfg={
	id="ESP8266.Shadow",
	dob="04/18/2021",
	rev="3",
	app="mqtt_ioc",
	wifi={
		ssid= "<your WiFi SSID>",
		pwd= "<your WiFi password>"
	},
	mqtt={
		host="TheShadowsHouse.IoT",
		port=1883,
		topics={
			cmd="/TheShadowsHouse/IoT/cmd",
			notif="/TheShadowsHouse/IoT/notif",
			status="/TheShadowsHouse/IoT/status",
		}
	},
	bootTime={sec=0, usec=0, rate=0},
	debug=true,
	start=true,
	heartbeat={
		enabled=true,
		interval=5000,
		ts={sec=0, usec=0, rate=0}
	},
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
}
-- get cfg API
function get_cfg()
	return dev_cfg
end
-- try/catch API
function try(f, f_catch)
	local status, exception = pcall(f)
	if not status then
		f_catch(exception)
	end
end
-- debug log API
function log_debug(msg)
	if dev_cfg.debug then
		print(dev_cfg.id.." "..msg)
	end
end
