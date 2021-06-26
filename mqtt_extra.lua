----------------------------------------
-- mqtt_extra.lua                     --
-- desc   : mqtt core functions       --
-- rev    : 1.0                       --
-- date   : 05/01/2021                --
-- author : tuan nguyen (pdxtigre)    --
-- email  : info@codesmiths.org       --
-- website: https://codesmiths.org    --
----------------------------------------

local mc = {MOD_NAME="mc"}

function mc:list_files(client)
	self:publish_content(client, file.list())
end

function mc:publish_file(client, filename)
	try(
		function()
			file.close()
			file.open(filename)
			self:publish_content(client, "@bof@")
			repeat
				local file_content = file.read(1024)
				if file_content then self:publish_content(client, file_content) end
			until not file_content
			self:publish_content(client, "@eof@")
			file.close()
		end,
		function(ex)
			log_debug("Error while reading file "..tostring(filename))
			log_debug("Reason: "..tostring(ex))
		end
	)
end

function mc:publish_content(client, content)	
	try(
		function()
			local cfg = get_cfg()
			local payload = {}
			payload.notif = "notif"
			payload.id = cfg.client_id
			payload.content = content
			client:publish(cfg.mqtt.topics.notif, sjson.encode(payload), 0, 0)
			cfg = nil
		end,
		function(ex)
			log_debug("Error while packaging MQTT payload "..tostring(content))
			log_debug("Reason: "..tostring(ex))
		end
	)	
end

function mc:do_heartbeat(content)	
	try(
		function()			
			local cfg = get_cfg()
			if cfg.heartbeat.enabled then
				local payload = {}
				cfg.heartbeat.ts.sec, cfg.heartbeat.ts.usec, cfg.heartbeat.ts.rate = rtctime.get()
				payload.notif="heartbeat"
				payload.id = cfg.client_id
				payload.content=content
				payload.uptime=tmr.time()
				payload.ts=cfg.heartbeat.ts
				payload.io = cfg.io.digital
				payload.hs = node.heap()
				cfg.client:publish(cfg.mqtt.topics.status, sjson.encode(payload), 0, 0)				
				timer:alarm(cfg.heartbeat.interval, tmr.ALARM_SINGLE, function() flashMod("mc"):do_heartbeat("") end)
			end
			cfg = nil
		end,
		function(ex)
			log_debug("Error while sending heartbeat")
			log_debug("Reason: "..tostring(ex))
		end
	)
end

flashMod(mc)