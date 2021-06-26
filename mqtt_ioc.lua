----------------------------------------
-- mqtt_ioc.lua           --
-- desc   : io control over mqtt      --
-- rev    : 2.0                       --
-- date   : 04/27/2021                --
-- author : tuan nguyen (pdxtigre)    --
-- email  : info@codesmiths.org       --
-- website: https://codesmiths.org    --
----------------------------------------

local mqtt_ioc = {MOD_NAME="mqtt_ioc"}

function mqtt_ioc:command_handler(client, payload)		
	try(
		function()
			local cfg = get_cfg()
			local pack = sjson.decode(payload)
			if pack.content then
				if pack.id == cfg.id then
					if pack.cmd == "open" then file.open(pack.content,"w+")
					elseif pack.cmd == "write" then file.write(pack.content)
					elseif pack.cmd == "close" then file.close()
					elseif pack.cmd == "remove" then file.remove(pack.content)
					elseif pack.cmd == "run" then dofile(pack.content)
					elseif pack.cmd == "read" then cfg.client:publish_file(client, pack.content)
					elseif pack.cmd == "list" then cfg.client:list_files(client)
					elseif pack.cmd == "reset" then node.restart()
					elseif pack.cmd == "hello" then cfg.client:publish_content(client, "hello")
					elseif pack.cmd == "ioc" then 
						-- log_debug("ioc --> "..pack.content.action.." "..pack.content.pinName)
						flashMod("ioc")[pack.content.action](nil, cfg, pack.content.pinName)
						flashMod("mc"):publish_content(client, "ACK")
					else log_debug("Not understood payload "..payload) end
				elseif pack.cmd == "hello" then cfg.client:publish_content(client, "hello")
				else log_debug("Payload not meant for me "..payload) end
			end
			cfg = nil
		end,
		function(ex)
			log_debug("Error while processing payload "..payload)
			log_debug("Reason: "..tostring(ex))
		end
	)	
end

function mqtt_ioc:start()	
	try(
		function()
			local cfg = get_cfg()
			-- keep the message handlers in memory
			cfg.handlers = {}
			cfg.handlers[cfg.mqtt.topics.cmd] = self.command_handler
			-- init io
			local ioc = flashMod("ioc")
			ioc:init(cfg)			
			-- init mqtt client
			local mc = flashMod("mc")
			mc:init()
			mc:start()
			cfg = nil
		end,
		function(ex)
			log_debug("Error while starting the application")
			log_debug("Reason: "..tostring(ex))
		end
	)	
end

flashMod(mqtt_ioc)