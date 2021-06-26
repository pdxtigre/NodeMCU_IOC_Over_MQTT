----------------------------------------
-- main.lua                           --
-- desc   : main lua app              --
-- rev    : 2.0                       --
-- date   : 05/01/2021                --
-- author : tuan nguyen (pdxtigre)    --
-- email  : info@codesmiths.org       --
-- website: https://codesmiths.org    --
----------------------------------------
local main = {MOD_NAME="main"}

-- startup application
function main:start_app()
	local cfg = get_cfg()
	collectgarbage()
	log_debug("Starting main application "..cfg.app.." "..node.heap())
	flashMod(cfg.app):start()
	cfg = nil
end

function main:time_sync()	
	try(function()
		local cfg = get_cfg()
		log_debug("Sync'ing time with NTP server..")
		sntp.sync(nil, nil, nil, 1)
		cfg.bootTime.sec, cfg.bootTime.usec, cfg.bootTime.rate = rtctime.get()
		cfg = nil
	end,
	function(ex)
		log_debug("Error while sync'ing with NTP server")
		log_debug("Reason: "..tostring(ex))
	end)
end

function main:on_WiFi_connected()
	log_debug("WiFi: connected, IP: "..wifi.sta.getip())
	self:time_sync()
	self:start_app()
end

-- attemp to establish a WiFi connection
function main:start_wifi()
	-- configure ESP as a station
	local cfg = get_cfg()
	local station_cfg={}
	log_debug("WiFi: setting up..")
	station_cfg.ssid=cfg.wifi.ssid
	station_cfg.pwd=cfg.wifi.pwd
	station_cfg.save=false
	station_cfg.auto=true

	wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(t)
		log_debug("WiFi: connected")
	end)

	wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(t)
		log_debug("WiFi: disconnected, restarting node after 10 seconds "..t.reason)
		timer:alarm(10000, tmr.ALARM_SINGLE, function() node.restart() end)		
	end)	

	wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(t)
		log_debug("WiFi: got IP: "..t.IP..", subnet mask: "..t.netmask..", gateway: "..t.gateway)
		dev_cfg.wifi.ip = t.IP
		flashMod("main"):on_WiFi_connected()
	end)
	
	log_debug("WiFi: connecting to "..cfg.wifi.ssid)
	wifi.setmode(wifi.STATION)
	wifi.sta.config(station_cfg)
	cfg = nil
end

-- power test API
function main:check_input_power()
	if adc.force_init_mode(adc.INIT_VDD33) then
		node.restart()
		return -- don't bother continuing, the restart is scheduled
	end
	vdd = adc.readvdd33()
	log_debug("System voltage Vdd = "..vdd.." mV")
end

-- main
function main:start()
	-- check the input power in case we power with battery
	-- check_input_power()	
	-- start WiFi
	collectgarbage()
	try(function()
		self:start_wifi()
	end,
	function(ex)
		log_debug("Error while starting WiFi")
		log_debug("Reason: "..tostring(ex))
	end)
end

flashMod(main)