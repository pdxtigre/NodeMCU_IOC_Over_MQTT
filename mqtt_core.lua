----------------------------------------
-- mqtt_core.lua                      --
-- desc   : mqtt core functions       --
-- rev    : 3.0                       --
-- date   : 05/01/2021                --
-- author : tuan nguyen (pdxtigre)    --
-- email  : info@codesmiths.org       --
-- website: https://codesmiths.org    --
----------------------------------------

local mc = {MOD_NAME="mc"}

function mc:handle_message(client, topic, payload)
	local cfg = get_cfg()
	log_debug("MQTT "..topic.." --> "..payload)
	if payload ~= nil and cfg.handlers[topic] then
		cfg.handlers[topic](nil, client, payload)
	end
	cfg = nil
end

function mc:do_connect()
	local cfg = get_cfg()
	log_debug("Connecting to MQTT broker..")		
	cfg.client:connect(cfg.mqtt.host, cfg.mqtt.port, false)
	cfg = nil
end

function mc:do_reconnect()
	timer:alarm(5000, tmr.ALARM_SINGLE, function() flashMod("mc"):do_connect() end)
end

function mc:handle_connect(client)	
	try(
		function()			
			local cfg = get_cfg()
			log_debug("Connected to MQTT broker.."..node.heap())
			client:subscribe(cfg.mqtt.topics.cmd, 0, function(client) log_debug("Subscribed successfully to: "..get_cfg().mqtt.topics.cmd) end)			
			-- sending the heartbeat the first time
			timer:alarm(1000, tmr.ALARM_SINGLE, function() 
				collectgarbage()
				log_debug("Sending heartbeat for the 1st time.."..node.heap())
				flashMod("mc"):do_heartbeat("bootup") 
				end)
			cfg = nil
		end,
		function(ex)
			log_debug("Error while handling MQTT connected event")
			log_debug("Reason: "..tostring(ex))
		end
	)	
end

function mc:handle_error(client, reason)
	log_debug("Failed to connect to MQTT server, reason: "..reason..", retrying in 5 s..")	
	self:do_reconnect()
end

function mc:handle_offline(client)
	log_debug("Disconnected from MQTT broker, retrying in 5 s.."..node.heap())	
	self:do_reconnect()
end

function mc:init()
	log_debug("Initializing MQTT client.."..node.heap())
	local cfg = get_cfg()
	local m = mqtt.Client()
	
	m:on("connect", function(client) flashMod("mc"):handle_connect(client) end)
	m:on("connfail", function(client, reason) flashMod("mc"):handle_error(client, reason) end)
	m:on("offline", function(client) flashMod("mc"):handle_offline(client) end)
	m:on("message", function(client, topic, payload) flashMod("mc"):handle_message(client, topic, payload) end)	

	cfg.client = m
	cfg.client_id = {
		device_id=cfg.id,
		chip_id=string.format("0x%x", node.chipid()),
		flash_id=string.format("0x%x", node.flashid()),
		ip=cfg.wifi.ip
	}
	cfg = nil
	timer:alarm(1000, tmr.ALARM_SINGLE, function() flashMod("mc"):do_connect() end)
end

function mc:start()
	log_debug("Starting MQTT client.."..node.heap())
	flashMod("mc"):do_connect()
end

flashMod(mc)